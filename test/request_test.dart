import 'dart:async';
import 'dart:convert';

import 'package:app/global_app_state.dart';
import 'package:app/main.dart';
import 'package:app/model/response/example_entity.dart';
import 'package:app/request/api_exception.dart';
import 'package:app/request/request.dart';
import 'package:app/services/example_services.dart';
import 'package:app/tool/pagination_controller.dart';
import 'package:app/tool/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ResponseBody body(int status, Map<String, dynamic> data) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class _Adapter implements HttpClientAdapter {
  _Adapter(this.send);
  final Future<ResponseBody> Function(RequestOptions) send;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => send(options);

  @override
  void close({bool force = false}) {}
}

class _FailFirstTokenWrite extends SharedPreferencesHelper {
  bool _failed = false;
  @override
  Future<bool> setString(String key, String value) {
    if (key == 'token' && !_failed) {
      _failed = true;
      return Future.value(false);
    }
    return super.setString(key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('PonnamKarthik/fluttertoast');
  var sequence = 0;
  var toastCount = 0;
  late String token;

  setUp(() async {
    token = 'test-session-${sequence++}';
    toastCount = 0;
    SharedPreferences.setMockInitialValues({
      'token': token,
      'userinfo': '{"id":7}',
      'keep': 'unchanged',
    });
    await sharedPreferencesInstance.init();
    globalAppStateInstance.restore();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'showToast') toastCount++;
          return true;
        });
  });

  tearDown(() async {
    await globalAppStateInstance.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Request request(Future<ResponseBody> Function(RequestOptions) send) {
    final dio = Dio()..httpClientAdapter = _Adapter(send);
    addTearDown(() => dio.close(force: true));
    return Request(client: dio);
  }

  test('custom options retain the default token and custom headers', () async {
    late RequestOptions options;
    final client = request((received) async {
      options = received;
      return body(200, {'code': 1, 'data': {}});
    });
    await client.get(
      '/example/detail',
      opts: Options(headers: {'X-Test': 'value'}),
      data: {'id': 1},
    );
    expect(options.headers['Token'], token);
    expect(options.headers['X-Test'], 'value');
    expect(options.queryParameters['id'], 1);
    expect(options.path, '/api/example/detail');
  });

  test(
    'startup restores the same token for pages and outgoing requests',
    () async {
      expect(globalAppStateInstance.isLogin, isTrue);
      expect(globalAppStateInstance.userinfo, {'id': 7});
      final client = request((options) async {
        expect(options.headers['Token'], globalAppStateInstance.token);
        return body(200, {'code': 1});
      });
      await client.get('/detail');
    },
  );

  test('malformed cached profile leaves the restored token usable', () async {
    SharedPreferences.setMockInitialValues({
      'token': token,
      'userinfo': '{broken',
    });
    await sharedPreferencesInstance.init();
    globalAppStateInstance.restore();
    expect(globalAppStateInstance.token, token);
    expect(globalAppStateInstance.userinfo, isNull);
  });

  test(
    'a late expiration cannot clear a login that reused the same token',
    () async {
      final pending = Completer<ResponseBody>();
      final started = Completer<void>();
      final previous = request((_) {
        started.complete();
        return pending.future;
      }).get('/previous');
      await started.future;
      await globalAppStateInstance.setToken(token);
      pending.complete(body(401, {'msg': 'previous session ended'}));
      await expectLater(previous, throwsA(isA<DioException>()));
      expect(globalAppStateInstance.token, token);
      expect(sharedPreferencesInstance.getString('token'), token);
      expect(toastCount, 0);
    },
  );

  test(
    'each new login can expire even if it reuses an expired token',
    () async {
      final client = request((_) async => body(200, {'code': '401'}));
      await client.get('/first');
      expect(globalAppStateInstance.isLogin, isFalse);
      await globalAppStateInstance.setToken(token);
      await client.get('/second');
      await Future<void>.delayed(Duration.zero);
      expect(globalAppStateInstance.isLogin, isFalse);
      expect(sharedPreferencesInstance.getString('token'), isNull);
      expect(toastCount, 2);
    },
  );

  test(
    'a login submitted during expiry is the session restored from disk',
    () async {
      final version = globalAppStateInstance.sessionVersion;
      final expired = globalAppStateInstance.expireIfCurrent(version, token);
      final signIn = globalAppStateInstance.setToken('next-session');
      final profile = globalAppStateInstance.setUserinfo({'id': 9});
      await Future.wait([signIn, profile]);
      expect(await expired, isFalse);
      expect(sharedPreferencesInstance.getString('keep'), 'unchanged');
      globalAppStateInstance.restore();
      expect(globalAppStateInstance.token, 'next-session');
      expect(globalAppStateInstance.userinfo, {'id': 9});
    },
  );

  test(
    'HTTP 401 honors both per-request status handling and token overrides',
    () async {
      final client = request((options) async {
        expect(options.extra['trace'], 'example');
        return body(401, {'msg': 'expired'});
      });
      Options options(String value) => Options(
        headers: {'Token': value},
        extra: {'trace': 'example'},
        validateStatus: (status) => status == 401,
      );
      await client.get('/other', opts: options('other-token'));
      expect(globalAppStateInstance.token, token);
      await client.get('/current', opts: options(token));
      expect(globalAppStateInstance.isLogin, isFalse);
      await client.get('/guest', opts: options(''));
      await Future<void>.delayed(Duration.zero);
      expect(toastCount, 1);
    },
  );

  test(
    'retrying a failed session write cannot pair a new profile with an old token',
    () async {
      final preferences = _FailFirstTokenWrite();
      await preferences.init();
      final state = GlobalAppState(preferences)..restore();
      addTearDown(state.dispose);
      await expectLater(state.setToken('retry-session'), throwsStateError);
      await state.setUserinfo({'id': 9});
      state.restore();
      expect(state.token, 'retry-session');
      expect(state.userinfo, {'id': 9});
    },
  );

  for (final status in [404, 500]) {
    test('HTTP $status completes with an error instead of hanging', () async {
      final client = request((_) async => body(status, {'msg': 'failed'}));
      await expectLater(
        client.get('/error').timeout(const Duration(seconds: 2)),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status',
            status,
          ),
        ),
      );
    });
  }

  test('business 401 completes and only clears authentication data', () async {
    final client = request(
      (_) async => body(200, {'code': 401, 'msg': 'expired'}),
    );
    final result = await client
        .get('/expired')
        .timeout(const Duration(seconds: 2));
    expect(result['code'], 401);
    expect(globalAppStateInstance.isLogin, isFalse);
    expect(sharedPreferencesInstance.getString('token'), isNull);
    expect(sharedPreferencesInstance.getString('userinfo'), isNull);
    expect(sharedPreferencesInstance.getString('keep'), 'unchanged');
    await Future<void>.delayed(Duration.zero);
    expect(toastCount, 1);
  });

  test('concurrent expired requests only notify once across clients', () async {
    final clientA = request((_) async => body(200, {'code': 401}));
    final clientB = request((_) async => body(200, {'code': 401}));
    await Future.wait([clientA.get('/a'), clientB.get('/b')]);
    await Future<void>.delayed(Duration.zero);
    expect(toastCount, 1);
  });

  test('an old session response cannot log out a newer session', () async {
    final pending = Completer<ResponseBody>();
    final started = Completer<void>();
    final client = request((_) {
      started.complete();
      return pending.future;
    });
    final response = client.get('/slow');
    await started.future;
    await globalAppStateInstance.setToken('new-session');
    pending.complete(body(200, {'code': 401}));
    await response;
    expect(globalAppStateInstance.token, 'new-session');
    expect(sharedPreferencesInstance.getString('token'), 'new-session');
    expect(toastCount, 0);
  });

  test('HTTP 401 also completes while handling session expiry', () async {
    final client = request((_) async => body(401, {'msg': 'expired'}));
    await expectLater(client.get('/expired'), throwsA(isA<DioException>()));
    expect(globalAppStateInstance.isLogin, isFalse);
  });

  test('cancellation completes without an expiry notification', () async {
    final started = Completer<void>();
    final pending = Completer<ResponseBody>();
    final cancel = CancelToken();
    final client = request((_) {
      started.complete();
      return pending.future;
    });
    final response = client.get('/slow', t: cancel);
    final assertion = expectLater(
      response,
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );
    await started.future;
    cancel.cancel('test');
    await assertion;
    pending.complete(body(200, {'code': 1}));
    expect(toastCount, 0);
  });

  group('typed example responses', () {
    const item = {
      'id': 1,
      'title': 'sample',
      'description': '',
      'create_time': 10,
    };
    Request reply(Map<String, dynamic> data) =>
        request((_) async => body(200, data));
    final formatError = isA<ApiException>().having(
      (error) => error.message,
      'message',
      currentAppLocalizations.responseFormatError,
    );

    test(
      'detail, list and page keep their typed results and allow empty lists',
      () async {
        final detail = await ExampleServices.getDetail(
          id: 1,
          request: reply({'code': 1, 'data': item}),
        );
        expect(detail?.title, 'sample');
        final list = await ExampleServices.getList(
          request: reply({
            'code': '1',
            'data': [item],
          }),
        );
        expect(list.single.id, 1);
        expect(
          await ExampleServices.getList(
            request: reply({'code': 1, 'data': []}),
          ),
          isEmpty,
        );
        final page = await ExampleServices.getPage(
          request: reply({
            'code': 1,
            'data': {
              'total': 0,
              'current_page': 1,
              'per_page': 20,
              'last_page': 1,
              'data': [],
            },
          }),
        );
        expect(page.data, isEmpty);
        expect(page.currentPage, 1);
      },
    );

    test(
      'business errors preserve the server code and message with any error payload',
      () async {
        final response = reply({
          'code': 23,
          'msg': 'Unavailable',
          'data': {'data': 'other shape'},
        });
        final error = isA<ApiException>()
            .having((e) => e.code, 'code', 23)
            .having((e) => e.message, 'message', 'Unavailable');
        await expectLater(
          ExampleServices.getList(request: response),
          throwsA(error),
        );
        await expectLater(
          ExampleServices.getPage(request: response),
          throwsA(error),
        );
        expect(
          await ExampleServices.getDetail(id: 1, request: response),
          isNull,
        );
      },
    );

    test(
      'invalid success data yields a format error instead of an empty result',
      () async {
        for (final data in <Object?>[
          null,
          [],
          'invalid',
          {},
          {'data': null},
          {'data': 'invalid'},
          {
            'data': [null],
          },
        ]) {
          await expectLater(
            ExampleServices.getPage(request: reply({'code': 1, 'data': data})),
            throwsA(formatError),
          );
        }
        for (final data in <Object?>[
          null,
          {},
          [null],
        ]) {
          await expectLater(
            ExampleServices.getList(request: reply({'code': 1, 'data': data})),
            throwsA(formatError),
          );
        }
        await expectLater(
          ExampleServices.getPage(
            request: reply({
              'data': {'data': []},
            }),
          ),
          throwsA(formatError),
        );
        await expectLater(
          ExampleServices.getDetail(
            id: 1,
            request: reply({'code': 1, 'data': null}),
          ),
          throwsA(formatError),
        );
      },
    );

    test(
      'a malformed next page keeps the list and page number available for retry',
      () async {
        var fail = true;
        final client = request((options) async {
          final page = options.queryParameters['page'];
          return body(200, {
            'code': 1,
            'data': page == 2 && fail
                ? {}
                : {
                    'current_page': page,
                    'last_page': 2,
                    'data': [
                      {...item, 'id': page},
                    ],
                  },
          });
        });
        final controller = PaginationController<ExampleEntity>(
          loadPage: (page, limit) => ExampleServices.getPage(
            page: page,
            limit: limit,
            request: client,
          ),
        );
        addTearDown(controller.dispose);
        await controller.refresh();
        await controller.loadMore();
        expect(controller.error, formatError);
        expect(controller.page, 1);
        expect(controller.items.single.id, 1);
        fail = false;
        await controller.retry();
        expect(controller.page, 2);
        expect(controller.items.map((item) => item.id), [1, 2]);
      },
    );
  });

  testWidgets('loading overlay closes after a request failure', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (current) {
            context = current;
            return const Scaffold(body: Text('content'));
          },
        ),
      ),
    );
    final pending = Completer<ResponseBody>();
    final client = request((_) => pending.future);
    final assertion = expectLater(
      client.get('/failure', showLoading: true, context: context),
      throwsA(isA<DioException>()),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(body(500, {'msg': 'failed'}));
    await tester.pumpAndSettle();
    await assertion;
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
