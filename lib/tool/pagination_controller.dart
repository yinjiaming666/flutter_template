import 'dart:async';
import 'dart:collection';

import 'package:app/model/response/page_resp_entity.dart';
import 'package:flutter/foundation.dart';

/// 与 UI 无关的分页状态；loader 失败必须抛出异常，不能返回空页冒充成功。
class PaginationController<T> extends ChangeNotifier {
  PaginationController({required this.loadPage, this.pageSize = 20, this.itemKey}) : assert(pageSize > 0);

  final Future<PageData<T>> Function(int page, int limit) loadPage;
  final int pageSize;
  final Object Function(T item)? itemKey;
  List<T> _items = [];
  int _page = 0;
  int _receivedCount = 0;
  int _version = 0;
  bool _initialized = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _disposed = false;
  bool _failedRefresh = true;
  Object? _error;
  Future<void>? _pending;

  List<T> get items => UnmodifiableListView(_items);
  int get page => _page;
  bool get initialized => _initialized;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoading => _isRefreshing || _isLoadingMore;
  bool get hasMore => _hasMore;
  Object? get error => _error;

  /// 刷新默认保留数据；clear 用于切换筛选条件，force 用于替代正在进行的刷新。
  Future<void> refresh({bool clear = false, bool force = false}) {
    if (_disposed) return Future<void>.value();
    if (_isRefreshing && !clear && !force) return _pending!;
    return _start(refresh: true, clear: clear);
  }

  Future<void> loadMore() {
    if (_disposed) return Future<void>.value();
    if (_pending != null) return _pending!;
    if (!_initialized) return refresh();
    if (!_hasMore) return Future<void>.value();
    return _start(refresh: false);
  }

  Future<void> retry() => _failedRefresh ? refresh() : loadMore();

  Future<void> _start({required bool refresh, bool clear = false}) {
    final version = ++_version;
    final nextPage = refresh ? 1 : _page + 1;
    final completer = Completer<void>();
    _pending = completer.future;
    _error = null;
    _isRefreshing = refresh;
    _isLoadingMore = !refresh;
    if (clear) {
      _items = [];
      _page = 0;
      _receivedCount = 0;
      _initialized = false;
      _hasMore = true;
    }
    notifyListeners();
    unawaited(_request(version, nextPage, refresh, completer));
    return completer.future;
  }

  Future<void> _request(int version, int nextPage, bool refresh, Completer<void> completer) async {
    try {
      final result = await loadPage(nextPage, pageSize);
      if (_disposed || version != _version) return;
      // 先准备新快照，异常不会破坏已有列表。
      final List<T> nextItems = refresh ? [] : List<T>.of(_items);
      final keyOf = itemKey;
      final seen = keyOf == null ? null : nextItems.map(keyOf).toSet();
      for (final item in result.data) {
        if (keyOf == null || seen!.add(keyOf(item))) nextItems.add(item);
      }
      final received = (refresh ? 0 : _receivedCount) + result.data.length;
      final effectivePageSize = result.perPage > 0 ? result.perPage : pageSize;
      final hasMore =
          result.data.isNotEmpty &&
          (result.lastPage > 0
              ? nextPage < result.lastPage
              : result.total > 0
              ? received < result.total
              : result.data.length >= effectivePageSize);
      _items = nextItems;
      _receivedCount = received;
      _page = nextPage;
      _hasMore = hasMore;
      _initialized = true;
    } catch (error) {
      if (_disposed || version != _version) return;
      _error = error;
      _failedRefresh = refresh;
    } finally {
      if (!_disposed && version == _version) {
        _pending = null;
        _isRefreshing = false;
        _isLoadingMore = false;
        notifyListeners();
      }
      completer.complete();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _version++;
    _pending = null;
    super.dispose();
  }
}
