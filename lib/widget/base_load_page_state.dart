import 'dart:async';

import 'package:app/l10n/l10n.dart';
import 'package:app/widget/app_skeleton.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:flutter/material.dart';

enum PageLoadStatus { loading, success, empty, error }

enum PageLoadResult { success, failure, ignored }

/// 有整页加载流程的页面 State 父类。
///
/// 子类实现 loadData 和 buildContent，可用 buildLoadBody 自定义区域布局。
/// loadData 只返回数据，失败时抛出异常；数据写入和请求版本由父类管理。
/// 分页、多个 Tab 的独立数据和局部加载由各自组件管理。
abstract class BaseLoadPageState<W extends StatefulWidget, D extends Object>
    extends BasePageState<W> {
  PageLoadStatus _loadStatus = PageLoadStatus.loading;
  D? _pageData;
  Object? _loadError;
  StackTrace? _loadStackTrace;
  bool _isLoading = false;
  bool _refreshingByPull = false;
  bool _initialLoadStarted = false;
  Completer<PageLoadResult>? _pendingLoad;

  PageLoadStatus get loadStatus => _loadStatus;

  D? get pageData => _pageData;

  Object? get loadError => _loadError;

  StackTrace? get loadStackTrace => _loadStackTrace;

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isLoading && _pageData != null;

  @protected
  bool get autoLoad => true;

  @protected
  Future<D> loadData();

  @protected
  Widget buildContent(BuildContext context, D data);

  @protected
  bool isEmpty(D data) => false;

  @protected
  Widget buildEmpty(BuildContext context) =>
      Center(child: Text(context.l10n.noData));

  @protected
  Widget buildError(BuildContext context, Object error) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.loadFailed, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading ? null : () => reload(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  /// 刷新失败时保留原内容，使用行内反馈；可按页面需求重写。
  @protected
  Widget buildRefreshError(BuildContext context, Object error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(context.l10n.refreshFailedKeepData),
          TextButton(
            onPressed: isLoading ? null : () => reload(),
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }

  /// 页面已有刷新指示器时，可重写为 SizedBox.shrink。
  @protected
  Widget buildRefreshIndicator(BuildContext context) =>
      const LinearProgressIndicator();

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialLoadStarted) {
      _initialLoadStarted = true;
      if (autoLoad) {
        unawaited(reload());
      }
    }
  }

  /// 同时调用默认合并为同一次请求。
  ///
  /// force 开启新请求并使旧结果失效；clearData 还会清除旧内容、重显骨架，
  /// 适用于切换记录或筛选条件。普通刷新保留已有内容和滚动子树。
  /// fromPull 保留失败视图并由下拉控件显示刷新进度。
  /// 已退出或被新请求取代时立即返回 ignored。
  Future<PageLoadResult> reload({
    bool force = false,
    bool clearData = false,
    bool fromPull = false,
  }) {
    if (!mounted) {
      return Future.value(PageLoadResult.ignored);
    }
    final pending = _pendingLoad;
    if (pending != null && !force && !clearData) {
      return pending.future;
    }

    final completer = Completer<PageLoadResult>();
    _pendingLoad = completer;
    pending?.complete(PageLoadResult.ignored);
    setState(() {
      if (clearData) {
        _pageData = null;
      }
      _isLoading = true;
      _refreshingByPull = fromPull;
      final keepError =
          fromPull && !clearData && _loadStatus == PageLoadStatus.error;
      if (!keepError) {
        _loadError = null;
        _loadStackTrace = null;
        if (_pageData == null) {
          _loadStatus = PageLoadStatus.loading;
        }
      }
    });
    unawaited(_performLoad(completer));
    return completer.future;
  }

  Future<void> _performLoad(Completer<PageLoadResult> completer) async {
    var result = PageLoadResult.ignored;
    try {
      final D data = await loadData();
      if (!mounted || !identical(_pendingLoad, completer)) {
        return;
      }
      final PageLoadStatus status = isEmpty(data)
          ? PageLoadStatus.empty
          : PageLoadStatus.success;
      setState(() {
        _pageData = data;
        _loadStatus = status;
        _loadError = null;
        _loadStackTrace = null;
      });
      result = PageLoadResult.success;
    } catch (error, stackTrace) {
      if (!mounted || !identical(_pendingLoad, completer)) {
        return;
      }
      setState(() {
        _loadError = error;
        _loadStackTrace = stackTrace;
        if (_pageData == null) {
          _loadStatus = PageLoadStatus.error;
        }
      });
      result = PageLoadResult.failure;
    } finally {
      if (mounted && identical(_pendingLoad, completer)) {
        _pendingLoad = null;
        setState(() => _isLoading = false);
        completer.complete(result);
      }
    }
  }

  @override
  Widget buildPageBody(BuildContext context) => buildLoadBody(context);

  /// 在页面 build 中使用；调用位置需要提供有界高度。
  @protected
  Widget buildLoadBody(BuildContext context) {
    final Widget content = switch (_loadStatus) {
      PageLoadStatus.loading => AppSkeleton(child: buildSkeleton(context)),
      PageLoadStatus.success => buildContent(context, _pageData as D),
      PageLoadStatus.empty => buildEmpty(context),
      PageLoadStatus.error => buildError(context, _loadError!),
    };
    // 通知区与内容区位置固定，刷新时不替换已有内容的父节点。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRefreshing && !_refreshingByPull)
              buildRefreshIndicator(context),
            if (_pageData != null && _loadError != null)
              buildRefreshError(context, _loadError!),
          ],
        ),
        Expanded(child: content),
      ],
    );
  }

  @override
  @mustCallSuper
  void dispose() {
    final pending = _pendingLoad;
    _pendingLoad = null;
    pending?.complete(PageLoadResult.ignored);
    super.dispose();
  }
}
