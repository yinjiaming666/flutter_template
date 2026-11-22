# 页面基类、骨架屏与路由

页面可继承 `BasePage`，对应的 State 继承 `BasePageState<页面类型>`。普通页面实现 `buildPageBody` 即可，标题栏可通过 `buildAppBar` 提供。基类默认提供 Scaffold 和 SafeArea，需要全屏布局时可重写 `useSafeArea`。

## 按需使用

| 能力 | 调用方式 |
| --- | --- |
| 骨架屏 | `showSkeleton()` 切换内容区为骨架屏，`hideSkeleton()` 恢复内容。可重写 `buildSkeleton` 定制占位布局 |
| 刷新 | `buildRefreshBody` 接收 `onRefresh`、`onLoad` 和滚动内容。将 builder 提供的 `physics` 传给滚动容器 |
| 路由 | `pushPage<T>()` 打开页面并等待类型化结果，`popPage<T>()` 返回结果 |
| 固定区域 | `wrapPageBody` 可在内容区外放置筛选栏或其他固定组件 |

加载时机、请求方法、数据、空态和失败反馈由子类管理。将 `hideSkeleton()` 放在 `finally` 中，确保失败时也能恢复内容。下拉刷新可以直接调用子类的加载方法，由 EasyRefresh 展示刷新进度并保留当前内容。

```dart
import 'dart:async';

import 'package:app/widget/base_page_state.dart';
import 'package:flutter/material.dart';

class ExamplePage extends BasePage {
  const ExamplePage({super.key});

  @override
  BasePageState<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends BasePageState<ExamplePage> {
  List<String> _items = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadData(showPlaceholder: true));
  }

  Future<void> _loadData({bool showPlaceholder = false}) async {
    if (showPlaceholder) showSkeleton();
    try {
      final items = await Future<List<String>>.delayed(
        const Duration(milliseconds: 400),
        () => ['第一条内容'],
      );
      if (mounted) setState(() => _items = items);
    } finally {
      if (showPlaceholder) hideSkeleton();
    }
  }

  @override
  Widget buildPageBody(BuildContext context) => buildRefreshBody(
    onRefresh: _loadData,
    builder: (context, physics) => ListView.builder(
      physics: physics,
      itemCount: _items.length,
      itemBuilder: (context, index) => ListTile(title: Text(_items[index])),
    ),
  );
}
```

模板的“骨架屏与路由示例”使用 `BaseLoadPageState<页面类型, 数据类型>`。子类实现 `loadData` 和 `buildContent`，按需覆盖骨架、空态或失败视图。基类合并同一次加载中的重复调用，刷新时保留旧内容，切换筛选用 `reload(clearData: true)` 清空旧内容并重显骨架。

下拉刷新使用 `reload(fromPull: true)`，由下拉控件显示进度。示例为空态和失败态也提供了可下拉的滚动容器。将 `PageLoadResult.success`、`failure`、`ignored` 分别映射为 EasyRefresh 的 `IndicatorResult.success`、`fail`、`none`。请求被替换或页面销毁时，等待方立即收到 `ignored`，迟到响应也会被丢弃。

分页页面可在 `buildPageBody` 直接放置 `PagedListView`，由页面提供分页加载函数和控制器。[分页控制器](common-features.md#分页控制器)

## 路由声明和生命周期

新增页面时，在 `lib/router.dart` 的 `AppRoute` 中声明地址，并在 `Routes.configureRoutes` 为它登记构建器。业务调用直接传入 `AppRoute`，动态地址使用 `RouterHelper.pushPathForResult<T>()`。

构建器使用 `arguments.read<T>(key, defaultValue: ...)` 读取跳转参数，并通过构造函数传给页面。参数缺失或类型不符时使用默认值。可空类型可以接收显式的 `null`，路径和查询参数可通过 `arguments.parameters` 取得。

路由默认从右侧进入。可在 `AppRoute` 中配置转场的 `type` 和 `builder`，使用 `TransitionType.custom` 时同时提供构建器。跳转时可通过 `transition` 覆盖转场。目标路由未配置构建器时，自定义覆盖会回退到注册转场。

冷启动时，`Routes.generateInitialRoutes` 将登录入口和请求的目标页放入启动栈。带查询参数的根地址和登录地址直接打开登录页。命名路由和动态跳转共用 URI 解析，`RouteSettings.name` 保留原始地址。

页面基类通过根 Navigator 的观察器接入以下回调，页面可按需重写。

| 方法 | 触发时机 |
| --- | --- |
| `onPageVisible()` | 首次订阅且路由可见，或退栈当帧结束后仍位于栈顶 |
| `onPageCovered()` | 同一 Navigator 中新页面或弹层覆盖当前页 |
| `onPageReturned()` | 退栈当帧结束时，派发给最终栈顶页面 |
| `onPageLeaving()` | 当前路由被 pop |

编辑页保存后通过 `popPage<String>(新值)` 回传结果。返回 `true` 表示页面已退出栈顶。页面存在内部历史项时，先关闭对应的局部层再调用。用户发起返回时使用 `RouterHelper.back()`，由 `PopScope` 处理拦截。主动多级退栈可用 `RouterHelper.popUntil()`，最多回到当前 Navigator 的根页。

```dart
final title = await pushPage<String>(
  AppRoute.editExample,
  arguments: Routes.editExampleArguments(_title),
);
if (!mounted || title == null || title == _title) return;
_title = title;
await reload(force: true);
```

`pushPage<T>` 委托给 `RouterHelper.pushForResult<T>`。取消或返回类型不符时得到 null，也可传入 `replace` 或 `clearStack`。嵌套 Navigator 使用该 Navigator 注册的独立观察器，可重写 `routeObserver`。资源释放写在 `dispose`，并调用 `super.dispose()`。

## 验证

```bash
flutter analyze --no-pub
flutter test --no-pub test/page_state_test.dart
```
