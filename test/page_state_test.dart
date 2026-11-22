import 'dart:async';

import 'package:app/main.dart' show MyApp, navigatorKey;
import 'package:app/pages/example/edit_page.dart';
import 'package:app/pages/example/load_page.dart';
import 'package:app/pages/login/sms_login.dart';
import 'package:app/router.dart';
import 'package:app/tool/route_helper.dart';
import 'package:app/widget/app_easy_refresh.dart';
import 'package:app/widget/app_skeleton.dart';
import 'package:app/widget/base_load_page_state.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:fluro/fluro.dart' show Handler, TransitionType;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(Routes.configureRoutes);

  test('page route declarations survive repeated initialization', () {
    Routes.configureRoutes();
    expect(Routes.router.match(Navigator.defaultRouteName), isNotNull);
    for (final route in AppRoute.values) {
      expect(Routes.router.match(route.path), isNotNull, reason: route.name);
    }
    expect(Routes.router.match(AppRoute.editExample.path)?.route.transitionType, TransitionType.inFromRight);
  });

  Future<void> mountAppAt(WidgetTester tester, String location) async {
    final dispatcher = tester.binding.platformDispatcher;
    dispatcher.defaultRouteNameTestValue = location;
    addTearDown(dispatcher.clearDefaultRouteNameTestValue);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('cold start returns directly from the target to login', (
    tester,
  ) async {
    await mountAppAt(tester, '${AppRoute.editExample.path}?next=/index/index');
    expect(find.byType(EditPageExample), findsOneWidget);

    final navigator = navigatorKey.currentState!;
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.byType(SmsLoginPage), findsOneWidget);
    expect(navigator.canPop(), isFalse);
  });

  testWidgets('cold start at the root with a query opens only login', (
    tester,
  ) async {
    const location = '/?utm_source=shared';
    await mountAppAt(tester, location);
    final login = find.byType(SmsLoginPage);
    expect(login, findsOneWidget);
    expect(navigatorKey.currentState!.canPop(), isFalse);
    expect(ModalRoute.of(tester.element(login))?.settings.name, location);
  });

  testWidgets('back honors the current route pop guard', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _SkeletonHarness()));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final popEvents = <bool>[];
    final guardResult = navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PopScope<void>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) => popEvents.add(didPop),
          child: const Scaffold(body: Text('受保护的页面')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final guard = find.text('受保护的页面');
    expect(await RouterHelper.back(context: tester.element(guard)), isTrue);
    await tester.pumpAndSettle();
    expect(guard, findsOneWidget);
    expect(popEvents, [false]);

    navigator.pop();
    await tester.pumpAndSettle();
    await guardResult;
  });

  testWidgets('only the current page can pop with a result', (tester) async {
    final key = GlobalKey<_SkeletonHarnessState>();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('入口页'))),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final pageResult = navigator.push<String>(
      MaterialPageRoute<String>(builder: (_) => _SkeletonHarness(key: key)),
    );
    await tester.pumpAndSettle();
    final dialog = showDialog<String>(
      context: key.currentContext!,
      builder: (_) => const AlertDialog(content: Text('上层弹窗')),
    );
    await tester.pumpAndSettle();

    expect(key.currentState!.finish('提前完成'), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('上层弹窗'), findsOneWidget);
    navigator.pop('弹窗结果');
    await tester.pumpAndSettle();
    expect(await dialog, '弹窗结果');

    expect(key.currentState!.finish('页面结果'), isTrue);
    await tester.pumpAndSettle();
    expect(await pageResult, '页面结果');
    expect(find.text('入口页'), findsOneWidget);
  });

  testWidgets('finishing a page preserves its local history until cleared', (
    tester,
  ) async {
    final key = GlobalKey<_SkeletonHarnessState>();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('入口页'))),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    final pageResult = navigator.push<String>(
      MaterialPageRoute<String>(builder: (_) => _SkeletonHarness(key: key)),
    );
    await tester.pumpAndSettle();

    var historyRemoved = false;
    final history = LocalHistoryEntry(onRemove: () => historyRemoved = true);
    ModalRoute.of(key.currentContext!)!.addLocalHistoryEntry(history);
    await tester.pump();

    expect(key.currentState!.finish('已保存'), isFalse);
    expect(historyRemoved, isFalse);
    expect(find.byType(_SkeletonHarness), findsOneWidget);

    history.remove();
    expect(historyRemoved, isTrue);
    expect(key.currentState!.finish('已保存'), isTrue);
    await tester.pumpAndSettle();
    expect(await pageResult, '已保存');
    expect(find.text('入口页'), findsOneWidget);
  });

  testWidgets('unsupported custom override uses the registered transition', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _SkeletonHarness()));
    final context = tester.element(find.byType(_SkeletonHarness));
    final result = RouterHelper.pushForResult<String>(
      context,
      AppRoute.editExample,
      transition: TransitionType.custom,
    );
    await tester.pumpAndSettle();
    expect(find.byType(EditPageExample), findsOneWidget);
    Navigator.of(context).pop('已打开');
    await tester.pumpAndSettle();
    expect(await result, '已打开');
  });

  testWidgets('dynamic paths retain parameters and registered custom transitions', (
    tester,
  ) async {
    var builtTransition = false;
    Map<String, List<String>>? receivedParameters;
    const location =
        '/route_test/42?next=/index/index?tab=1&filter=active&filter=archived';
    Routes.router.define(
      '/route_test/:id',
      handler: Handler(
        handlerFunc: (_, parameters) {
          receivedParameters = parameters;
          return const Scaffold(body: Text('动态路由'));
        },
      ),
      transitionType: TransitionType.custom,
      transitionBuilder: (_, _, _, child) {
        builtTransition = true;
        return child;
      },
    );
    await tester.pumpWidget(const MaterialApp(home: _SkeletonHarness()));
    final context = tester.element(find.byType(_SkeletonHarness));
    final result = RouterHelper.pushPathForResult<void>(
      context,
      location,
      transition: TransitionType.custom,
    );
    await tester.pumpAndSettle();
    final target = find.text('动态路由');
    expect(target, findsOneWidget);
    expect(receivedParameters, {
      'id': ['42'],
      'next': ['/index/index?tab=1'],
      'filter': ['active', 'archived'],
    });
    expect(ModalRoute.of(tester.element(target))?.settings.name, location);
    expect(builtTransition, isTrue);
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    await result;
  });

  testWidgets('nullable arguments distinguish missing keys from explicit null', (tester) async {
    await tester.pumpWidget(MaterialApp(home: const _SkeletonHarness(), onGenerateRoute: Routes.generateRoute));
    const fallback = '默认值';
    final home = tester.element(find.byType(_SkeletonHarness));
    expect(readArguments<String?>(home, 'value', defaultValue: fallback), fallback);

    final navigator = Navigator.of(home);
    final result = navigator.pushNamed<dynamic>(AppRoute.editExample.path, arguments: <String, dynamic>{'value': null});
    await tester.pumpAndSettle();
    final edit = tester.element(find.byType(EditPageExample));
    expect(readArguments<String?>(edit, 'value', defaultValue: fallback), isNull);
    expect(readArguments<String?>(edit, 'missing', defaultValue: fallback), fallback);
    navigator.pop();
    await tester.pumpAndSettle();
    await result;
  });

  Future<void> mountPage(
    WidgetTester tester, {
    required GlobalKey<_LoadHarnessState> pageKey,
    required Future<List<String>> Function() loader,
    RouteObserver<ModalRoute<dynamic>>? observer,
    List<String>? events,
  }) async {
    final routeObserver = observer ?? RouteObserver<ModalRoute<dynamic>>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],
        onGenerateRoute: Routes.generateRoute,
        home: _LoadHarness(key: pageKey, loader: loader, observer: routeObserver, events: events),
      ),
    );
  }

  testWidgets('first load uses the required skeleton and keeps the page header', (tester) async {
    final pending = Completer<List<String>>();
    final key = GlobalKey<_LoadHarnessState>();
    await mountPage(tester, pageKey: key, loader: () => pending.future);
    expect(find.byType(AppSkeleton), findsOneWidget);
    expect(find.text('固定标题'), findsOneWidget);
    pending.complete(['已加载']);
    await tester.pump();
    expect(find.byType(AppSkeleton), findsNothing);
    expect(find.text('已加载'), findsOneWidget);
  });

  Future<void> mountExample(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoadPageExample(),
        onGenerateRoute: Routes.generateRoute,
        navigatorObservers: [AppRouteObserver().routeObserver],
      ),
    );
    expect(find.byType(AppSkeleton), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  final refreshButton = find.widgetWithIcon(IconButton, Icons.refresh);

  Future<void> beginPull(WidgetTester tester, Finder scrollView) async {
    final start = tester.getTopLeft(scrollView) + const Offset(24, 24);
    await tester.dragFrom(start, const Offset(0, 320));
    for (var frame = 0; frame < 60; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (tester.widget<IconButton>(refreshButton).onPressed == null) return;
    }
    fail('EasyRefresh did not invoke onRefresh after the drag');
  }

  testWidgets('base page displays a skeleton only when the subclass asks for it', (tester) async {
    final key = GlobalKey<_SkeletonHarnessState>();
    await tester.pumpWidget(MaterialApp(home: _SkeletonHarness(key: key)));
    final state = key.currentState!;
    expect(find.text('普通内容'), findsOneWidget);
    expect(find.byType(AppSkeleton), findsNothing);
    expect(find.byType(AppEasyRefresh), findsNothing);

    state.showPlaceholder();
    await tester.pump();
    expect(find.byType(AppSkeleton), findsOneWidget);
    expect(find.text('普通内容'), findsNothing);

    state.hidePlaceholder();
    await tester.pump();
    expect(find.byType(AppSkeleton), findsNothing);
    expect(find.text('普通内容'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    state.showPlaceholder();
    state.hidePlaceholder();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the load example retains short content during pull to refresh', (tester) async {
    await mountExample(tester);
    expect(tester.widget<IconButton>(refreshButton).onPressed, isNotNull);
    await beginPull(tester, find.byType(ListView));
    expect(find.text('页面内容'), findsOneWidget);
    expect(find.byType(AppSkeleton), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('页面内容'), findsOneWidget);
    expect(tester.widget<IconButton>(refreshButton).onPressed, isNotNull);
  });

  for (final firstLoadFails in [false, true]) {
    testWidgets('the load example allows a pull on the ${firstLoadFails ? 'error' : 'empty'} state', (tester) async {
      await mountExample(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, firstLoadFails ? '加载失败' : '空数据'));
      await tester.pump();
      expect(find.byType(AppSkeleton), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text(firstLoadFails ? '加载失败，请重试' : '暂无数据'), findsOneWidget);

      await beginPull(tester, find.byType(CustomScrollView));
      expect(find.byType(AppSkeleton), findsNothing);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(tester.widget<IconButton>(refreshButton).onPressed, isNotNull);

      final refresh = tester.widget<AppEasyRefresh>(find.byType(AppEasyRefresh));
      final result = refresh.onRefresh!();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        await result,
        firstLoadFails ? IndicatorResult.fail : IndicatorResult.success,
      );
      await tester.pumpAndSettle();
    });
  }

  testWidgets('the load example updates after its edit route returns a new title', (tester) async {
    await mountExample(tester);
    expect(find.text('页面内容'), findsOneWidget);

    await tester.tap(find.text('编辑标题'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '新标题');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('新标题'), findsOneWidget);
    expect(find.text('页面内容'), findsNothing);
  });

  testWidgets('concurrent reload calls reuse the current request', (tester) async {
    final pending = Completer<List<String>>();
    final key = GlobalKey<_LoadHarnessState>();
    var calls = 0;
    await mountPage(
      tester,
      pageKey: key,
      loader: () {
        calls++;
        return pending.future;
      },
    );
    final first = key.currentState!.reload();
    final second = key.currentState!.reload();
    expect(identical(first, second), isTrue);
    expect(calls, 1);
    pending.complete(['结果']);
    expect(await first, PageLoadResult.success);
    await tester.pump();
    expect(key.currentState!.isLoading, isFalse);
  });

  testWidgets('synchronous failure finishes loading and can be retried', (tester) async {
    final key = GlobalKey<_LoadHarnessState>();
    var shouldFail = true;
    var calls = 0;
    await mountPage(
      tester,
      pageKey: key,
      loader: () {
        calls++;
        if (shouldFail) throw StateError('同步失败');
        return Future.value(['重试成功']);
      },
    );
    expect(find.text('加载失败，请重试'), findsOneWidget);
    expect(key.currentState!.isLoading, isFalse);
    shouldFail = false;
    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(calls, 2);
    expect(find.text('重试成功'), findsOneWidget);
    expect(key.currentState!.loadError, isNull);
  });

  testWidgets('empty data uses the empty state instead of an error', (tester) async {
    final key = GlobalKey<_LoadHarnessState>();
    await mountPage(tester, pageKey: key, loader: () async => []);
    await tester.pump();
    expect(find.text('暂无数据'), findsOneWidget);
    expect(key.currentState!.loadStatus, PageLoadStatus.empty);
    expect(key.currentState!.loadError, isNull);
  });

  testWidgets('refresh failure retains content and scroll position', (tester) async {
    final key = GlobalKey<_LoadHarnessState>();
    final refresh = Completer<List<String>>();
    var calls = 0;
    await mountPage(
      tester,
      pageKey: key,
      loader: () => calls++ == 0 ? Future.value(List.generate(60, (index) => '条目$index')) : refresh.future,
    );
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    final position = scrollable.position.pixels;
    final pending = key.currentState!.reload();
    await tester.pump();
    expect(find.byType(AppSkeleton), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(scrollable.position.pixels, position);
    refresh.completeError(StateError('刷新失败'));
    expect(await pending, PageLoadResult.failure);
    await tester.pump();
    expect(find.text('刷新失败，已保留原内容'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(scrollable.position.pixels, position);
    expect(key.currentState!.pageData!.length, 60);
    expect(key.currentState!.isRefreshing, isFalse);
  });

  testWidgets('a stale completion cannot end a newer load', (tester) async {
    final first = Completer<List<String>>();
    final second = Completer<List<String>>();
    final queue = [first, second];
    final key = GlobalKey<_LoadHarnessState>();
    await mountPage(tester, pageKey: key, loader: () => queue.removeAt(0).future);
    final pending = key.currentState!.reload(force: true);
    first.complete(['旧结果']);
    await tester.pump();
    expect(key.currentState!.isLoading, isTrue);
    expect(find.byType(AppSkeleton), findsOneWidget);
    expect(find.text('旧结果'), findsNothing);
    second.complete(['新结果']);
    await pending;
    await tester.pump();
    expect(find.text('新结果'), findsOneWidget);
  });

  testWidgets('a stale failure cannot replace a newer success', (tester) async {
    final first = Completer<List<String>>();
    final second = Completer<List<String>>();
    final queue = [first, second];
    final key = GlobalKey<_LoadHarnessState>();
    await mountPage(tester, pageKey: key, loader: () => queue.removeAt(0).future);
    final stale = key.currentState!.reload();
    PageLoadResult? staleResult;
    unawaited(stale.then<void>((result) => staleResult = result));
    final pending = key.currentState!.reload(force: true);
    await tester.pump();
    expect(staleResult, PageLoadResult.ignored);
    expect(first.isCompleted, isFalse);
    second.complete(['新结果']);
    expect(await pending, PageLoadResult.success);
    first.completeError(StateError('旧请求失败'));
    await tester.pump();
    expect(find.text('新结果'), findsOneWidget);
    expect(key.currentState!.loadError, isNull);
    expect(key.currentState!.loadStatus, PageLoadStatus.success);
  });

  testWidgets('clearData shows the skeleton when switching records', (tester) async {
    final next = Completer<List<String>>();
    final key = GlobalKey<_LoadHarnessState>();
    var calls = 0;
    await mountPage(tester, pageKey: key, loader: () => calls++ == 0 ? Future.value(['记录一']) : next.future);
    await tester.pump();
    final pending = key.currentState!.reload(clearData: true);
    await tester.pump();
    expect(find.text('记录一'), findsNothing);
    expect(find.byType(AppSkeleton), findsOneWidget);
    next.complete(['记录二']);
    await pending;
    await tester.pump();
    expect(find.text('记录二'), findsOneWidget);
  });

  testWidgets('disposed pages ignore pending errors and unsubscribe routes', (tester) async {
    final pending = Completer<List<String>>();
    final key = GlobalKey<_LoadHarnessState>();
    final observer = RouteObserver<ModalRoute<dynamic>>();
    await mountPage(tester, pageKey: key, loader: () => pending.future, observer: observer);
    final route = ModalRoute.of(key.currentContext!)!;
    final load = key.currentState!.reload();
    PageLoadResult? loadResult;
    unawaited(load.then<void>((result) => loadResult = result));
    expect(observer.debugObservingRoute(route), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(loadResult, PageLoadResult.ignored);
    expect(pending.isCompleted, isFalse);
    pending.completeError(StateError('已退出'));
    await tester.pump();
    expect(observer.debugObservingRoute(route), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('popUntil only restores the page left at the top', (tester) async {
    final observer = RouteObserver<ModalRoute<dynamic>>();
    final rootEvents = <String>[];
    final middleEvents = <String>[];
    await mountPage(
      tester,
      pageKey: GlobalKey<_LoadHarnessState>(),
      loader: () async => ['入口页'],
      observer: observer,
      events: rootEvents,
    );
    await tester.pumpAndSettle();
    final navigator = navigatorKey.currentState!;
    final middle = navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _LoadHarness(
          key: GlobalKey<_LoadHarnessState>(),
          loader: () async => ['中间页'],
          observer: observer,
          events: middleEvents,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final top = navigator.push<void>(
      MaterialPageRoute<void>(builder: (_) => const _SkeletonHarness()),
    );
    await tester.pumpAndSettle();
    rootEvents.clear();
    middleEvents.clear();

    RouterHelper.popUntil(ModalRoute.withName(Navigator.defaultRouteName));
    await tester.pumpAndSettle();
    expect(rootEvents, ['visible', 'returned']);
    expect(middleEvents, isEmpty);
    expect(find.text('入口页'), findsOneWidget);
    await middle;
    await top;
  });

  testWidgets('typed route results notify lifecycle without automatic reload', (tester) async {
    final key = GlobalKey<_LoadHarnessState>();
    final events = <String>[];
    var calls = 0;
    await mountPage(
      tester,
      pageKey: key,
      loader: () async {
        calls++;
        return ['原内容'];
      },
      events: events,
    );
    await tester.pump();
    final result = RouterHelper.pushForResult<String>(
      key.currentContext!,
      AppRoute.editExample,
      arguments: <String, dynamic>{'value': '原标题'},
      transition: TransitionType.none,
    );
    await tester.pumpAndSettle();
    expect(events, ['visible', 'covered']);
    expect(tester.widget<EditPageExample>(find.byType(EditPageExample)).initialValue, '原标题');
    final field = find.byType(TextFormField);
    await tester.enterText(field, '新标题');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(await result, '新标题');
    expect(events, ['visible', 'covered', 'visible', 'returned']);
    expect(calls, 1);
  });

  testWidgets('named routes use the page fallback for invalid arguments', (tester) async {
    await tester.pumpWidget(MaterialApp(home: const _SkeletonHarness(), onGenerateRoute: Routes.generateRoute));
    final navigator = Navigator.of(tester.element(find.byType(_SkeletonHarness)));
    final result = navigator.pushNamed<dynamic>(AppRoute.editExample.path, arguments: <String, dynamic>{'value': 123});
    await tester.pumpAndSettle();
    expect(tester.widget<EditPageExample>(find.byType(EditPageExample)).initialValue, isEmpty);
    navigator.pop();
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });

  testWidgets('modal routes with bool results also notify the underlying page', (tester) async {
    final key = GlobalKey<_LoadHarnessState>();
    final events = <String>[];
    await mountPage(tester, pageKey: key, loader: () async => ['内容'], events: events);
    await tester.pump();
    final result = showDialog<bool>(
      context: key.currentContext!,
      builder: (context) => AlertDialog(
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('关闭弹层'))],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('关闭弹层'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
    expect(events, ['visible', 'covered', 'visible', 'returned']);
  });

  testWidgets('mismatched route result types safely return null', (tester) async {
    final key = GlobalKey<_LoadHarnessState>();
    await mountPage(tester, pageKey: key, loader: () async => ['内容']);
    await tester.pump();
    final result = RouterHelper.pushForResult<String>(
      key.currentContext!,
      AppRoute.editExample,
      transition: TransitionType.none,
    );
    await tester.pumpAndSettle();
    await RouterHelper.back(
      context: tester.element(find.byType(EditPageExample)),
      params: 123,
    );
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });

  testWidgets('navigation from a disposed context safely returns null', (tester) async {
    final key = GlobalKey<_LoadHarnessState>();
    await mountPage(tester, pageKey: key, loader: () async => ['内容']);
    await tester.pump();
    final context = key.currentContext!;
    await tester.pumpWidget(const SizedBox.shrink());
    expect(
      await RouterHelper.pushForResult<String>(context, AppRoute.editExample),
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('skeleton uses the current theme and excludes placeholder actions', (tester) async {
    final theme = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue));
    var taps = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: AppSkeleton(
            child: Column(
              children: [
                const SkeletonBox(key: ValueKey('bone'), width: 80, height: 24),
                TextButton(onPressed: () => taps++, child: const Text('占位按钮')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('占位按钮'), warnIfMissed: false);
    expect(taps, 0);
    expect(find.bySemanticsLabel('正在加载'), findsOneWidget);
    expect(find.bySemanticsLabel('占位按钮'), findsNothing);
    final decoration = tester.widget<DecoratedBox>(
      find.descendant(of: find.byKey(const ValueKey('bone')), matching: find.byType(DecoratedBox)),
    );
    expect((decoration.decoration as BoxDecoration).color, theme.colorScheme.surfaceContainerHighest);
    semantics.dispose();
  });
}

class _SkeletonHarness extends BasePage {
  const _SkeletonHarness({super.key});

  @override
  BasePageState<_SkeletonHarness> createState() => _SkeletonHarnessState();
}

class _SkeletonHarnessState extends BasePageState<_SkeletonHarness> {
  bool finish(String result) => popPage(result);

  void showPlaceholder() => showSkeleton();

  void hidePlaceholder() => hideSkeleton();

  @override
  Widget buildPageBody(BuildContext context) => const Center(child: Text('普通内容'));
}

class _LoadHarness extends StatefulWidget {
  const _LoadHarness({
    required GlobalKey<_LoadHarnessState> key,
    required this.loader,
    required this.observer,
    this.events,
  }) : super(key: key);

  final Future<List<String>> Function() loader;
  final RouteObserver<ModalRoute<dynamic>> observer;
  final List<String>? events;

  @override
  State<_LoadHarness> createState() => _LoadHarnessState();
}

class _LoadHarnessState extends BaseLoadPageState<_LoadHarness, List<String>> {
  @override
  RouteObserver<ModalRoute<dynamic>> get routeObserver => widget.observer;

  @override
  Future<List<String>> loadData() => widget.loader();

  @override
  bool isEmpty(List<String> data) => data.isEmpty;

  @override
  Widget buildSkeleton(BuildContext context) => const SkeletonBox();

  @override
  Widget buildContent(BuildContext context, List<String> data) =>
      ListView(children: data.map((item) => ListTile(title: Text(item))).toList());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('固定标题')),
    body: buildLoadBody(context),
  );

  @override
  void onPageVisible() => widget.events?.add('visible');

  @override
  void onPageCovered() => widget.events?.add('covered');

  @override
  void onPageReturned() => widget.events?.add('returned');
}
