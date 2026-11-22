import 'package:app/tool/app_route_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart' show nonVirtual;

/// 普通 State 也可单独使用的路由生命周期。
///
/// 只通知可见、覆盖、返回和退出事件，不自动刷新数据。
/// 这些事件描述当前 Navigator 的路由栈，不代表应用前后台或 Tab 可见性。
mixin PageRouteAwareMixin<W extends StatefulWidget> on State<W>
    implements RouteAware {
  ModalRoute<dynamic>? _subscribedRoute;
  RouteObserver<ModalRoute<dynamic>>? _subscribedObserver;
  int _returnNotification = 0;

  @protected
  RouteObserver<ModalRoute<dynamic>> get routeObserver =>
      AppRouteObserver().routeObserver;

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final RouteObserver<ModalRoute<dynamic>> observer = routeObserver;
    if (identical(route, _subscribedRoute) &&
        identical(observer, _subscribedObserver)) {
      return;
    }

    _subscribedObserver?.unsubscribe(this);
    _returnNotification++;
    _subscribedRoute = route;
    _subscribedObserver = observer;
    // 嵌套 Navigator 未提供匹配的观察器时，不订阅其他 Navigator 的路由。
    if (route != null && identical(observer.navigator, route.navigator)) {
      observer.subscribe(this, route);
    }
  }

  /// 首次订阅且当前路由可见，或上层路由返回。
  @protected
  void onPageVisible() {}

  /// 被新页面或同一 Navigator 的弹层覆盖。
  @protected
  void onPageCovered() {}

  /// 上层路由返回。默认不重新请求，页面自行决定是否 reload。
  @protected
  void onPageReturned() {}

  /// 当前路由被 pop。资源的最终释放仍放在 dispose。
  @protected
  void onPageLeaving() {}

  @override
  @nonVirtual
  void didPush() {
    if (_subscribedRoute?.isCurrent ?? false) {
      onPageVisible();
    }
  }

  @override
  @nonVirtual
  void didPushNext() => onPageCovered();

  @override
  @nonVirtual
  void didPopNext() {
    final notification = ++_returnNotification;
    final binding = WidgetsBinding.instance;
    // 多级退栈过程中，只有帧结束时仍位于栈顶的页面需要恢复。
    binding.addPostFrameCallback((_) {
      if (!_canNotifyReturn(notification)) return;
      onPageVisible();
      if (_canNotifyReturn(notification)) onPageReturned();
    });
    binding.ensureVisualUpdate();
  }

  bool _canNotifyReturn(int notification) =>
      mounted &&
      notification == _returnNotification &&
      _subscribedRoute?.isCurrent == true;

  @override
  @nonVirtual
  void didPop() => onPageLeaving();

  @override
  @mustCallSuper
  void dispose() {
    _subscribedObserver?.unsubscribe(this);
    _subscribedRoute = null;
    _subscribedObserver = null;
    super.dispose();
  }
}
