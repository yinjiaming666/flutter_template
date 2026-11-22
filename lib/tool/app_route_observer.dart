import 'package:flutter/widgets.dart';

/// 根 Navigator 使用的路由观察器。
///
/// 嵌套 Navigator 应创建独立观察器，并在 PageRouteAwareMixin 中重写
/// routeObserver；一个观察器只能注册到一个 Navigator。
class AppRouteObserver {
  static final AppRouteObserver _instance = AppRouteObserver._();

  final RouteObserver<ModalRoute<dynamic>> routeObserver =
      RouteObserver<ModalRoute<dynamic>>();

  AppRouteObserver._();

  factory AppRouteObserver() => _instance;
}
