import 'package:app/pages/index/index.dart';
import 'package:app/pages/login/sms_login.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class Routes {
  static final FluroRouter router = FluroRouter();

  static const String firstPage = '/login/sms_login';
  static const String loginPage = '/login/sms_login';
  static const String indexPage = '/index/index';

  static void _initRouter() {
    router.define(
      '/',
      handler: Handler(handlerFunc: (_, __) => const SmsLoginPage()),
    );
    router.define(
      loginPage,
      handler: Handler(handlerFunc: (_, __) => const SmsLoginPage()),
    );
    router.define(
      indexPage,
      handler: Handler(handlerFunc: (_, __) => const IndexPage()),
    );
  }

  static void configureRoutes() {
    router.notFoundHandler = Handler(
      handlerFunc: (_, __) {
        return const Scaffold(body: Center(child: Text('页面不存在')));
      },
    );
    _initRouter();
  }
}

class AppRouteObserver {
  static final RouteObserver<ModalRoute<void>> _routeObserver =
      RouteObserver<ModalRoute<void>>();
  static final AppRouteObserver _appRouteObserver =
      AppRouteObserver._internal();

  AppRouteObserver._internal();

  RouteObserver<ModalRoute<void>> get routeObserver => _routeObserver;

  factory AppRouteObserver() {
    return _appRouteObserver;
  }
}

T readArguments<T>(
  BuildContext context,
  String key, {
  required T defaultValue,
}) {
  final Object? args = ModalRoute.of(context)?.settings.arguments;
  if (args is! Map<String, dynamic>) {
    return defaultValue;
  }
  final Object? value = args[key];
  if (value is T) {
    return value;
  }
  return defaultValue;
}
