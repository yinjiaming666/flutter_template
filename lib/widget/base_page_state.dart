import 'dart:async';

import 'package:app/router.dart' show AppRoute;
import 'package:app/tool/page_route_aware_mixin.dart';
import 'package:app/tool/route_helper.dart' show RouterHelper;
import 'package:app/widget/app_easy_refresh.dart';
import 'package:app/widget/app_skeleton.dart';
import 'package:fluro/fluro.dart' show TransitionType;
import 'package:flutter/material.dart';

/// 使用通用页面布局的 Widget 基类。
abstract class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  BasePageState<BasePage> createState();
}

/// 提供页面布局、骨架屏控制、刷新容器与路由能力。
/// 数据请求、空态和失败反馈由页面 State 实现。
abstract class BasePageState<W extends StatefulWidget> extends State<W>
    with PageRouteAwareMixin<W> {
  bool _skeletonVisible = false;

  @protected
  bool get useSafeArea => true;

  @protected
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  @protected
  Widget buildPageBody(BuildContext context);

  /// [body] 是会随页面状态切换的内容区，默认直接显示它。
  ///
  /// 例如订单页需要始终显示筛选栏时，可以重写此方法，把筛选栏放在 [body] 上方。
  /// 这样下方切换为骨架屏、订单列表或重试按钮时，筛选栏仍然可见。
  @protected
  Widget wrapPageBody(BuildContext context, Widget body) => body;

  @protected
  void showSkeleton() => _setSkeletonVisible(true);

  @protected
  void hideSkeleton() => _setSkeletonVisible(false);

  void _setSkeletonVisible(bool visible) {
    if (!mounted || visible == _skeletonVisible) return;
    setState(() => _skeletonVisible = visible);
  }

  @protected
  Widget buildSkeleton(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SkeletonBox(width: 144, height: 24),
          ),
          SizedBox(height: 16),
          SkeletonBox(),
          SizedBox(height: 8),
          SkeletonBox(),
        ],
      ),
    );
  }

  @protected
  Widget buildRefreshBody({
    required Widget Function(BuildContext context, ScrollPhysics physics)
    builder,
    FutureOr<dynamic> Function()? onRefresh,
    FutureOr<dynamic> Function()? onLoad,
  }) {
    return AppEasyRefresh(
      childBuilder: builder,
      onRefresh: onRefresh,
      onLoad: onLoad,
    );
  }

  @protected
  Future<T?> pushPage<T>(
    AppRoute route, {
    Object? arguments,
    bool replace = false,
    bool clearStack = false,
    TransitionType? transition,
  }) {
    if (!mounted) return Future<T?>.value();
    return RouterHelper.pushForResult<T>(
      context,
      route,
      arguments: arguments,
      replace: replace,
      clearStack: clearStack,
      transition: transition,
    );
  }

  /// 主动完成当前页并回传结果，返回该路由是否已退出栈顶。
  /// 页面有内部历史项时，由页面先关闭对应局部层再重试。
  @protected
  bool popPage<T>([T? result]) {
    if (!mounted) return false;
    final route = ModalRoute.of(context);
    final navigator = route?.navigator;
    if (route == null ||
        !route.isCurrent ||
        route.willHandlePopInternally ||
        navigator == null ||
        !navigator.canPop()) {
      return false;
    }
    RouterHelper.dismissKeyboard(context);
    navigator.pop<T>(result);
    return !route.isCurrent;
  }

  @override
  Widget build(BuildContext context) {
    final body = Builder(
      builder: (context) {
        final content = _skeletonVisible
            ? AppSkeleton(child: buildSkeleton(context))
            : buildPageBody(context);
        return wrapPageBody(context, content);
      },
    );
    return Scaffold(
      appBar: buildAppBar(context),
      body: useSafeArea ? SafeArea(child: body) : body,
    );
  }
}
