import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class RouterHelper {
  static void push(
    BuildContext context,
    String path, {
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
    TransitionType? transition,
  }) {
    if (!context.mounted) {
      return;
    }
    Routes.router.navigateTo(
      context,
      path,
      replace: replace,
      clearStack: clearStack,
      transition: transition ?? TransitionType.inFromRight,
      routeSettings: RouteSettings(name: path, arguments: arguments),
    );
  }

  static void switchTab(
    String path, {
    bool replace = false,
    bool clearStack = true,
    Object? arguments,
  }) {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    Routes.router.navigateTo(
      context,
      path,
      replace: replace,
      clearStack: clearStack,
      transition: TransitionType.inFromRight,
      routeSettings: RouteSettings(name: path, arguments: arguments),
    );
  }

  static void back({int count = 1, Object? params, BuildContext? context}) {
    if (context != null && !context.mounted) {
      return;
    }
    final BuildContext? currentContext = context ?? navigatorKey.currentContext;
    if (currentContext == null) {
      return;
    }
    final NavigatorState state = Navigator.of(currentContext);
    while (count-- > 0 && state.canPop()) {
      state.pop(params);
    }
  }

  static void pushWithNoContext(
    String path, {
    bool replace = false,
    bool clearStack = false,
    Object? arguments,
    TransitionType? transition,
  }) {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    Routes.router.navigateTo(
      context,
      path,
      replace: replace,
      clearStack: clearStack,
      transition: transition ?? TransitionType.inFromRight,
      routeSettings: RouteSettings(name: path, arguments: arguments),
    );
  }
}
