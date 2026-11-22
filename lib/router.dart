import 'package:app/l10n/l10n.dart';
import 'package:app/pages/example/edit_page.dart';
import 'package:app/pages/example/load_page.dart';
import 'package:app/pages/example/media_page.dart';
import 'package:app/pages/example/pagination_page.dart';
import 'package:app/pages/example/widgets_page.dart';
import 'package:app/pages/index/index.dart';
import 'package:app/pages/login/sms_login.dart';
import 'package:app/widget/base_page_state.dart' show BasePage, BasePageState;
import 'package:fluro/fluro.dart' show FluroRouter, Handler, TransitionType;
import 'package:flutter/material.dart';

export 'package:app/tool/app_route_observer.dart';

/// 应用内页面的路由标识和地址。
enum AppRoute {
  login('/login/sms_login'),
  home('/index/index'),
  loadExample('/example/load_page'),
  editExample(
    '/example/edit_page',
    transition: (type: TransitionType.inFromRight, builder: null),
  ),
  widgetsExample('/example/widgets'),
  paginationExample('/example/pagination'),
  mediaExample('/example/media');

  const AppRoute(
    this.path, {
    this.transition = (type: TransitionType.inFromRight, builder: null),
  });

  final String path;
  final ({TransitionType type, RouteTransitionsBuilder? builder}) transition;
}

class Routes {
  static final FluroRouter router = FluroRouter();

  static const _editValueKey = 'value';
  static bool _configured = false;

  static Map<String, String> editExampleArguments(String value) => {
    _editValueKey: value,
  };

  static void configureRoutes() {
    if (_configured) return;

    final pages = <AppRoute, Widget Function(PageRouteArguments)>{
      AppRoute.login: (_) => const SmsLoginPage(),
      AppRoute.home: (_) => const IndexPage(),
      AppRoute.loadExample: (_) => const LoadPageExample(),
      AppRoute.editExample: (arguments) => EditPageExample(
        initialValue: arguments.read<String>(_editValueKey, defaultValue: ''),
      ),
      AppRoute.widgetsExample: (_) => const CommonWidgetsExample(),
      AppRoute.paginationExample: (_) => const PaginationExample(),
      AppRoute.mediaExample: (_) => const MediaExamplePage(),
    };
    final routesByPath = <String, AppRoute>{
      Navigator.defaultRouteName: AppRoute.login,
    };
    for (final route in AppRoute.values) {
      if (route.path.isEmpty || !pages.containsKey(route)) {
        throw StateError('Route ${route.name} must have a path and a builder.');
      }
      if (routesByPath.containsKey(route.path)) {
        throw StateError('Route "${route.path}" is already declared.');
      }
      if ((route.transition.type == TransitionType.custom) !=
          (route.transition.builder != null)) {
        throw StateError(
          'Route "${route.path}" must pair a custom transition with a builder.',
        );
      }
      routesByPath[route.path] = route;
    }

    for (final entry in routesByPath.entries) {
      final route = entry.value;
      final buildPage = pages[route]!;
      router.define(
        entry.key,
        handler: Handler(
          handlerFunc: (context, parameters) {
            final settings = _routeSettingsOf(context);
            final routeParameters = entry.key == Navigator.defaultRouteName
                ? _queryParameters(Uri.tryParse(settings?.name ?? ''))
                : parameters;
            return buildPage(
              PageRouteArguments._(settings?.arguments, routeParameters),
            );
          },
        ),
        transitionType: route.transition.type,
        transitionBuilder: route.transition.builder,
      );
    }

    router.notFoundHandler = Handler(
      handlerFunc: (_, __) => const _NotFoundPage(),
    );
    _configured = true;
  }

  /// Fluro 按斜杠切分地址，先将查询参数编码以保留值中的分隔符。
  static String pathForMatching(String location) {
    final uri = Uri.tryParse(location);
    if (uri == null) return location.split('?').first;
    final path = uri.path;
    if (path == Navigator.defaultRouteName) return path;

    final parameters = _queryParameters(uri);
    if (parameters.isEmpty) return path;
    final query = Uri(queryParameters: parameters).query;
    return '$path?$query';
  }

  static Map<String, List<String>> _queryParameters(Uri? uri) {
    try {
      return uri?.queryParametersAll ?? const {};
    } on FormatException {
      return const {};
    }
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final location = settings.name;
    if (location == null) return null;
    return router
        .matchRoute(null, pathForMatching(location), routeSettings: settings)
        .route;
  }

  /// 启动时只放入入口页和请求的目标页。
  static List<Route<dynamic>> generateInitialRoutes(String location) {
    const entrySettings = RouteSettings(name: Navigator.defaultRouteName);
    final target = generateRoute(RouteSettings(name: location));
    final path = Uri.tryParse(location)?.path;
    if (target == null) return [generateRoute(entrySettings)!];
    if (path == Navigator.defaultRouteName || path == AppRoute.login.path) {
      return [target];
    }
    return [generateRoute(entrySettings)!, target];
  }
}

RouteSettings? _routeSettingsOf(BuildContext? context) =>
    context == null ? null : ModalRoute.of(context)?.settings;

/// 路由构建器可以读取跳转参数，以及 Fluro 解析的路径和查询参数。
final class PageRouteArguments {
  PageRouteArguments._(this._arguments, [this.parameters = const {}]);

  final Object? _arguments;
  final Map<String, List<String>> parameters;

  T read<T>(String key, {required T defaultValue}) {
    final arguments = _arguments;
    if (arguments is! Map<String, dynamic> || !arguments.containsKey(key)) {
      return defaultValue;
    }
    final Object? value = arguments[key];
    return value is T ? value : defaultValue;
  }
}

T readArguments<T>(
  BuildContext? context,
  String key, {
  required T defaultValue,
}) => PageRouteArguments._(
  _routeSettingsOf(context)?.arguments,
).read<T>(key, defaultValue: defaultValue);

class _NotFoundPage extends BasePage {
  const _NotFoundPage();

  @override
  BasePageState<_NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends BasePageState<_NotFoundPage> {
  @override
  Widget buildPageBody(BuildContext context) =>
      Center(child: Text(context.l10n.pageNotFound));
}
