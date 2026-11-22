import 'dart:async';

import 'package:app/l10n/l10n.dart';
import 'package:app/router.dart';
import 'package:app/widget/app_easy_refresh.dart';
import 'package:app/widget/app_skeleton.dart';
import 'package:app/widget/base_load_page_state.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:flutter/material.dart';

enum _ExampleMode { content, empty, error }

/// 使用本地数据演示父类和路由返回值，不依赖后端。
class LoadPageExample extends BasePage {
  const LoadPageExample({super.key});

  @override
  BasePageState<LoadPageExample> createState() => _LoadPageExampleState();
}

class _LoadPageExampleState
    extends BaseLoadPageState<LoadPageExample, List<String>> {
  _ExampleMode _mode = _ExampleMode.content;
  String _title = '';

  @override
  Future<List<String>> loadData() async {
    final mode = _mode;
    final title = _title;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return switch (mode) {
      _ExampleMode.content => [title],
      _ExampleMode.empty => const <String>[],
      _ExampleMode.error => throw StateError(
        defaultAppLocalizations.simulateLoadFailure,
      ),
    };
  }

  @override
  bool isEmpty(List<String> data) => data.isEmpty;

  Future<IndicatorResult> _refreshFromPull() async {
    if (isLoading) return IndicatorResult.none;
    final result = await reload(fromPull: true);
    return switch (result) {
      PageLoadResult.success => IndicatorResult.success,
      PageLoadResult.failure => IndicatorResult.fail,
      PageLoadResult.ignored => IndicatorResult.none,
    };
  }

  void _selectMode(_ExampleMode mode) {
    _mode = mode;
    unawaited(reload(clearData: true));
  }

  Future<void> _editTitle() async {
    final title = _title.isEmpty ? context.l10n.loadExampleContent : _title;
    final String? result = await pushPage<String>(
      AppRoute.editExample,
      arguments: Routes.editExampleArguments(title),
    );
    if (!mounted || result == null || result == title) {
      return;
    }
    _title = result;
    await reload(force: true);
  }

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(context.l10n.loadExampleTitle),
      actions: [
        IconButton(
          tooltip: context.l10n.refresh,
          onPressed: isLoading ? null : () => reload(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  @override
  Widget wrapPageBody(BuildContext context, Widget body) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _selectMode(_ExampleMode.content),
                child: Text(l10n.normalContent),
              ),
              OutlinedButton(
                onPressed: () => _selectMode(_ExampleMode.empty),
                child: Text(l10n.emptyExample),
              ),
              OutlinedButton(
                onPressed: () => _selectMode(_ExampleMode.error),
                child: Text(l10n.loadFailureExample),
              ),
            ],
          ),
        ),
        Expanded(child: body),
      ],
    );
  }

  @override
  Widget buildSkeleton(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBox(width: 180, height: 28),
          ),
          SizedBox(height: 12),
          SkeletonBox(),
          SizedBox(height: 8),
          SkeletonBox(),
          SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: SkeletonBox(width: 120, height: 40),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildEmpty(BuildContext context) =>
      _buildRefreshableState(Text(context.l10n.noData));

  @override
  Widget buildError(BuildContext context, Object error) {
    return _buildRefreshableState(
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          Text(context.l10n.loadFailed),
          TextButton(
            onPressed: isLoading ? null : () => reload(),
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshableState(Widget child) => buildRefreshBody(
    onRefresh: _refreshFromPull,
    builder: (context, physics) => CustomScrollView(
      physics: physics,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ],
    ),
  );

  @override
  Widget buildContent(BuildContext context, List<String> data) =>
      buildRefreshBody(
        onRefresh: _refreshFromPull,
        builder: (context, physics) => ListView(
          physics: physics,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              data.first.isEmpty ? context.l10n.loadExampleContent : data.first,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(context.l10n.loadExampleHint),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: _editTitle,
                child: Text(context.l10n.editTitle),
              ),
            ),
          ],
        ),
      );
}
