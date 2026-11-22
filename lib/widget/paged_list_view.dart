import 'dart:async';

import 'package:app/l10n/l10n.dart';
import 'package:app/tool/pagination_controller.dart';
import 'package:app/widget/app_easy_refresh.dart';
import 'package:flutter/material.dart';

/// 常规分页列表的可选组合；controller 由创建方释放。
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.padding,
    this.loadOnInit = true,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final bool loadOnInit;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
  final EasyRefreshController _refreshController = EasyRefreshController();
  bool _wasRefreshing = false;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  void _attach() {
    _wasRefreshing = widget.controller.isRefreshing;
    widget.controller.addListener(_changed);
    final controller = widget.controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          identical(controller, widget.controller) &&
          widget.loadOnInit &&
          !controller.initialized &&
          !controller.isLoading) {
        unawaited(controller.refresh());
      }
    });
  }

  void _changed() {
    final controller = widget.controller;
    if (_wasRefreshing &&
        !controller.isRefreshing &&
        controller.error == null) {
      _refreshController.resetFooter();
    }
    _wasRefreshing = controller.isRefreshing;
  }

  @override
  void didUpdateWidget(covariant PagedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_changed);
      _refreshController.resetFooter();
      _attach();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    _refreshController.dispose();
    super.dispose();
  }

  Future<IndicatorResult> _refresh() async {
    final controller = widget.controller;
    await controller.refresh();
    if (!mounted || !identical(controller, widget.controller)) {
      return IndicatorResult.fail;
    }
    return controller.error == null
        ? IndicatorResult.success
        : IndicatorResult.fail;
  }

  Future<IndicatorResult> _load() async {
    final controller = widget.controller;
    await controller.loadMore();
    if (!mounted || !identical(controller, widget.controller)) {
      return IndicatorResult.fail;
    }
    if (controller.error != null) return IndicatorResult.fail;
    return controller.hasMore
        ? IndicatorResult.success
        : IndicatorResult.noMore;
  }

  Widget _retry(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.loadFailed),
        TextButton(
          onPressed: widget.controller.isLoading
              ? null
              : () => widget.controller.retry(),
          child: Text(context.l10n.retry),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final items = controller.items;
        return AppEasyRefresh(
          controller: _refreshController,
          onRefresh: _refresh,
          onLoad: _load,
          enableLoad: controller.initialized && items.isNotEmpty,
          childBuilder: (context, physics) {
            if (items.isEmpty) {
              final Widget status;
              if (controller.isLoading ||
                  (!controller.initialized && controller.error == null)) {
                status =
                    widget.loadingBuilder?.call(context) ??
                    const Center(child: CircularProgressIndicator());
              } else if (controller.error != null) {
                status = Center(child: _retry(context));
              } else {
                status =
                    widget.emptyBuilder?.call(context) ??
                    Center(child: Text(context.l10n.noData));
              }
              return CustomScrollView(
                physics: physics,
                slivers: [
                  SliverFillRemaining(hasScrollBody: false, child: status),
                ],
              );
            }
            return ListView.builder(
              physics: physics,
              padding: widget.padding,
              itemCount: items.length + (controller.error != null ? 1 : 0),
              itemBuilder: (context, index) => index == items.length
                  ? _retry(context)
                  : widget.itemBuilder(context, items[index], index),
            );
          },
        );
      },
    );
  }
}
