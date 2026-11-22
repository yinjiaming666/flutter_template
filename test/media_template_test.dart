import 'dart:async';
import 'dart:convert';

import 'package:app/main.dart';
import 'package:app/request/http_log_interceptor.dart';
import 'package:app/router.dart';
import 'package:app/tool/permission.dart';
import 'package:app/widget/app_image_preview.dart';
import 'package:app/widget/app_media_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'permission requests coalesce and keep different system prompts sequential',
    () async {
      const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final cameraPrompt = Completer<Map<int, int>>();
      final cameraStarted = Completer<void>();
      final requested = <int>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'checkPermissionStatus') {
          return PermissionStatus.denied.index;
        }
        expect(call.method, 'requestPermissions');
        final value = (call.arguments as List<Object?>).single as int;
        requested.add(value);
        if (value == Permission.camera.value) {
          cameraStarted.complete();
          return cameraPrompt.future;
        }
        return {value: PermissionStatus.restricted.index};
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      final first = PermissionHelper.request(Permission.camera);
      final repeated = PermissionHelper.request(Permission.camera);
      final next = PermissionHelper.request(Permission.microphone);
      expect(identical(first, repeated), isTrue);
      await cameraStarted.future;
      expect(requested, [Permission.camera.value]);
      cameraPrompt.complete({
        Permission.camera.value: PermissionStatus.permanentlyDenied.index,
      });
      expect(await first, PermissionStatus.permanentlyDenied);
      expect(await next, PermissionStatus.restricted);
      expect(requested, [Permission.camera.value, Permission.microphone.value]);
    },
  );

  test(
    'HTTP diagnostics log metadata and leave response and error flows intact',
    () async {
      final capture = _LogCapture();
      final diagnosticLogger = Logger(
        output: capture,
        printer: SimplePrinter(colors: false),
      );
      addTearDown(diagnosticLogger.close);
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.interceptors
        ..add(HttpLogInterceptor(diagnosticLogger))
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path == '/timeout') {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.receiveTimeout,
                  ),
                  true,
                );
              } else {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: 'response-secret',
                  ),
                  true,
                );
              }
            },
          ),
        );
      addTearDown(dio.close);
      final response = await dio.post<String>(
        '/file?query=query-secret',
        options: Options(headers: {'Token': 'header-secret'}),
        data: 'body-secret',
      );
      expect(response.data, 'response-secret');
      await expectLater(dio.get('/timeout'), throwsA(isA<DioException>()));
      final logs = capture.lines.join('\n');
      expect(logs, contains('POST /file status=200'));
      expect(logs, contains('type=receiveTimeout'));
      expect(logs, isNot(contains('secret')));
    },
  );

  testWidgets(
    'mixed media retains each file type and enforces the selection limit',
    (tester) async {
      const channel = MethodChannel('plugins.flutter.io/image_picker');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'pickMedia');
        expect((call.arguments as Map)['limit'], 2);
        return ['/tmp/selected.jpg', '/tmp/selected.mov', '/tmp/overflow.png'];
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      List<PickedMedia>? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    selected = await AppMediaPicker.show(
                      context,
                      filter: AppMediaFilter.all,
                      maxItems: 2,
                    );
                  },
                  child: const Text('Open media picker'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open media picker'));
      await tester.pumpAndSettle();
      expect(find.text('拍照'), findsOneWidget);
      expect(find.text('录制视频'), findsOneWidget);
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      expect(selected?.map((item) => item.kind), [
        AppMediaKind.image,
        AppMediaKind.video,
      ]);
      expect(selected?.map((item) => item.source), [
        AppMediaSource.gallery,
        AppMediaSource.gallery,
      ]);
    },
  );

  testWidgets(
    'image preview pages by swipe, locks while zoomed and closes when dragged down',
    (tester) async {
      final pixel = MemoryImage(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aG/0AAAAASUVORK5CYII=',
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () =>
                      AppImagePreview.show(context, images: [pixel, pixel]),
                  child: const Text('Open preview'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open preview'));
      await tester.pumpAndSettle();
      final viewer = find.byType(PageView);
      expect(find.text('1 / 2'), findsOneWidget);
      await tester.drag(viewer, const Offset(-510, 0));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);

      Future<void> doubleTap() async {
        final center = tester.getCenter(viewer);
        await tester.tapAt(center);
        await tester.pump(const Duration(milliseconds: 60));
        await tester.tapAt(center);
        await tester.pumpAndSettle();
      }

      await doubleTap();
      final interactive = tester.widgetList<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(
        interactive.any(
          (widget) =>
              widget.transformationController!.value.getMaxScaleOnAxis() > 1,
        ),
        isTrue,
      );
      await tester.drag(viewer, const Offset(320, 0));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      await doubleTap();
      await tester.drag(viewer, const Offset(0, 220));
      await tester.pumpAndSettle();
      expect(find.byType(AppImagePreview), findsNothing);
      expect(find.text('Open preview'), findsOneWidget);
    },
  );

  testWidgets(
    'launch restores the chosen language and the language menu saves changes',
    (tester) async {
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({'app_language': 'en'});
        await sharedPreferencesInstance.init();
      });
      Routes.configureRoutes();
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
      await tester.tap(find.byTooltip('App language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('简体中文'));
      await tester.pumpAndSettle();
      expect(find.text('登录'), findsOneWidget);
      expect(sharedPreferencesInstance.getString('app_language'), 'zh');
    },
  );
}

class _LogCapture extends LogOutput {
  final lines = <String>[];

  @override
  void output(OutputEvent event) => lines.addAll(event.lines);
}
