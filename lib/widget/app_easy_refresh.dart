import 'dart:async';

import 'package:app/l10n/l10n.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

export 'package:easy_refresh/easy_refresh.dart'
    show EasyRefreshController, IndicatorResult, HeaderLocator, FooterLocator;

/// 只统一刷新交互。列表、网格或 Sliver 的布局仍由页面自己编写。
class AppEasyRefresh extends StatelessWidget {
  const AppEasyRefresh({
    super.key,
    required this.childBuilder,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableRefresh = true,
    this.enableLoad = true,
    this.useLocator = false,
    this.refreshOnStart = false,
  });

  final Widget Function(BuildContext context, ScrollPhysics physics)
  childBuilder;
  final EasyRefreshController? controller;
  final FutureOr<dynamic> Function()? onRefresh;
  final FutureOr<dynamic> Function()? onLoad;
  final bool enableRefresh;
  final bool enableLoad;
  final bool useLocator;
  final bool refreshOnStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final position = useLocator
        ? IndicatorPosition.locator
        : IndicatorPosition.behind;
    return EasyRefresh.builder(
      controller: controller,
      refreshOnStart: refreshOnStart,
      canRefreshAfterNoMore: true,
      header: ClassicHeader(
        position: position,
        clamping: useLocator,
        showMessage: false,
        textStyle: theme.textTheme.bodySmall,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        dragText: l10n.pullToRefresh,
        armedText: l10n.releaseToRefresh,
        readyText: l10n.refreshing,
        processingText: l10n.refreshing,
        processedText: l10n.refreshComplete,
        failedText: l10n.refreshFailed,
        noMoreText: l10n.noMoreData,
      ),
      footer: ClassicFooter(
        position: position,
        mainAxisAlignment: MainAxisAlignment.center,
        showMessage: false,
        textStyle: theme.textTheme.bodySmall,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        dragText: l10n.pullToLoad,
        armedText: l10n.releaseToLoad,
        readyText: l10n.loading,
        processingText: l10n.loading,
        processedText: l10n.loadComplete,
        failedText: l10n.loadFailureExample,
        noMoreText: l10n.noMoreData,
      ),
      notRefreshHeader: NotRefreshHeader(position: position, maxOverOffset: 0),
      notLoadFooter: NotLoadFooter(position: position, maxOverOffset: 0),
      onRefresh: enableRefresh ? onRefresh : null,
      onLoad: enableLoad ? onLoad : null,
      childBuilder: childBuilder,
    );
  }
}
