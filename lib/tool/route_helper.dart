import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:fluro/fluro.dart' show TransitionType;
import 'package:flutter/material.dart';

export 'package:app/router.dart' show readArguments;

class RouterHelper {
  static void dismissKeyboard([BuildContext? context]) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (context != null && context.mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  static Future<void> push(
    BuildContext context,
    AppRoute route, {
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
    TransitionType? transition,
  }) async {
    await pushForResult<Object?>(
      context,
      route,
      replace: replace,
      clearStack: clearStack,
      arguments: arguments,
      transition: transition,
    );
  }

  /// 返回目标页 pop 的结果；取消、context 失效或结果类型不符时返回 null。
  static Future<T?> pushForResult<T>(
    BuildContext context,
    AppRoute route, {
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
    TransitionType? transition,
  }) => pushPathForResult<T>(
    context,
    route.path,
    replace: replace,
    clearStack: clearStack,
    arguments: arguments,
    transition: transition,
  );

  /// 用于带路径参数或查询参数的动态地址。
  static Future<T?> pushPathForResult<T>(
    BuildContext context,
    String path, {
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
    TransitionType? transition,
  }) async {
    if (!context.mounted) {
      return null;
    }
    dismissKeyboard(context);
    final router = Routes.router;
    final matchPath = Routes.pathForMatching(path);
    final resolvedTransition =
        transition == TransitionType.custom &&
            router.match(matchPath)?.route.transitionBuilder == null
        ? null
        : transition;
    final Object? result = await router.navigateTo(
      context,
      matchPath,
      replace: replace,
      clearStack: clearStack,
      transition: resolvedTransition,
      routeSettings: RouteSettings(name: path, arguments: arguments),
    );
    return result is T ? result : null;
  }

  static Future<void> switchTab(
    AppRoute route, {
    bool replace = false,
    bool clearStack = true,
    Object? arguments,
  }) async {
    await pushWithNoContext<Object?>(
      route,
      replace: replace,
      clearStack: clearStack,
      arguments: arguments,
    );
  }

  /// 响应用户返回，交由当前路由处理 PopScope 和内部历史记录。
  static Future<bool> back({Object? params, BuildContext? context}) async {
    final navigator = _navigatorOf(context);
    if (navigator == null) {
      return false;
    }
    dismissKeyboard(context ?? navigator.context);
    return navigator.maybePop(params);
  }

  /// 主动退栈到指定路由，最多到当前 Navigator 的根页。
  static void popUntil(RoutePredicate predicate, {BuildContext? context}) {
    final navigator = _navigatorOf(context);
    if (navigator == null) {
      return;
    }
    dismissKeyboard(context ?? navigator.context);
    navigator.popUntil((route) => route.isFirst || predicate(route));
  }

  static Future<T?> pushWithNoContext<T>(
    AppRoute route, {
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
    TransitionType? transition,
  }) {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      return Future<T?>.value();
    }
    return pushForResult<T>(
      context,
      route,
      replace: replace,
      clearStack: clearStack,
      arguments: arguments,
      transition: transition,
    );
  }

  static NavigatorState? _navigatorOf(BuildContext? context) {
    if (context == null) {
      return navigatorKey.currentState;
    }
    return context.mounted ? Navigator.maybeOf(context) : null;
  }
}
