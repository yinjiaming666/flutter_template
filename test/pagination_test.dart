import 'dart:async';

import 'package:app/model/response/page_resp_entity.dart';
import 'package:app/tool/pagination_controller.dart';
import 'package:app/widget/app_easy_refresh.dart';
import 'package:app/widget/paged_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PageData<int> page(List<int> items, {int total = 0, int lastPage = 0, int perPage = 0}) => PageData<int>()
  ..data = items
  ..total = total
  ..lastPage = lastPage
  ..perPage = perPage;

void main() {
  test('commits page numbers after success and stops at the final page', () async {
    final calls = <int>[];
    final controller = PaginationController<int>(
      pageSize: 2,
      loadPage: (number, limit) async {
        calls.add(number);
        return page(number == 1 ? [1, 2] : [3], total: 3);
      },
    );
    addTearDown(controller.dispose);
    await controller.refresh();
    await controller.loadMore();
    await controller.loadMore();
    expect(calls, [1, 2]);
    expect(controller.page, 2);
    expect(controller.items, [1, 2, 3]);
    expect(controller.hasMore, isFalse);
  });

  test('deduplicates IDs but uses received count for the total', () async {
    final controller = PaginationController<int>(
      loadPage: (number, _) async => page(number == 1 ? [1, 2] : [2, 3], total: 4),
      itemKey: (item) => item,
    );
    addTearDown(controller.dispose);
    await controller.refresh();
    await controller.loadMore();
    expect(controller.items, [1, 2, 3]);
    expect(controller.hasMore, isFalse);
  });

  test('concurrent calls share a request and a failure retries the same page', () async {
    final first = Completer<PageData<int>>();
    final calls = <int>[];
    var failSecond = true;
    final controller = PaginationController<int>(
      loadPage: (number, _) {
        calls.add(number);
        if (number == 1) return first.future;
        if (failSecond) throw StateError('failed');
        return Future.value(page([3], total: 3));
      },
    );
    addTearDown(controller.dispose);
    final pending = controller.refresh();
    expect(identical(pending, controller.refresh()), isTrue);
    expect(identical(pending, controller.loadMore()), isTrue);
    first.complete(page([1, 2], total: 3));
    await pending;
    await controller.loadMore();
    expect(controller.page, 1);
    expect(controller.items, [1, 2]);
    expect(controller.isLoading, isFalse);
    failSecond = false;
    await controller.retry();
    expect(calls, [1, 2, 2]);
    expect(controller.page, 2);
    expect(controller.error, isNull);
  });

  test('refresh failure preserves previously loaded data and immutable snapshots', () async {
    var fail = false;
    final controller = PaginationController<int>(
      loadPage: (_, _) async {
        if (fail) throw StateError('failed');
        return page([1], total: 1);
      },
    );
    addTearDown(controller.dispose);
    await controller.refresh();
    final snapshot = controller.items;
    expect(() => snapshot.add(2), throwsUnsupportedError);
    fail = true;
    await controller.refresh();
    expect(controller.items, [1]);
    expect(controller.initialized, isTrue);
    expect(controller.error, isNotNull);
    fail = false;
    await controller.refresh(clear: true);
    expect(snapshot, [1]);
    expect(controller.error, isNull);
  });

  test('refresh supersedes an in-flight append and ignores its failure', () async {
    final append = Completer<PageData<int>>();
    var refreshed = false;
    final controller = PaginationController<int>(
      loadPage: (number, _) {
        if (number == 2) return append.future;
        return Future.value(page(refreshed ? [9] : [1], total: 2));
      },
    );
    addTearDown(controller.dispose);
    await controller.refresh();
    final old = controller.loadMore();
    refreshed = true;
    await controller.refresh(clear: true);
    append.completeError(StateError('stale'));
    await old;
    expect(controller.items, [9]);
    expect(controller.page, 1);
    expect(controller.error, isNull);
    expect(controller.isLoading, isFalse);
  });

  test('a stale refresh cannot finish a newer refresh', () async {
    final old = Completer<PageData<int>>();
    final current = Completer<PageData<int>>();
    final queue = [old, current];
    final controller = PaginationController<int>(loadPage: (_, _) => queue.removeAt(0).future);
    addTearDown(controller.dispose);
    final first = controller.refresh();
    final second = controller.refresh(force: true);
    old.complete(page([1], total: 1));
    await first;
    expect(controller.isRefreshing, isTrue);
    expect(controller.items, isEmpty);
    current.complete(page([2], total: 1));
    await second;
    expect(controller.items, [2]);
  });

  test('disposal ignores pending data and stops notifications', () async {
    final pending = Completer<PageData<int>>();
    final controller = PaginationController<int>(loadPage: (_, _) => pending.future);
    var changes = 0;
    controller.addListener(() => changes++);
    final request = controller.refresh();
    controller.dispose();
    pending.complete(page([1]));
    await request;
    expect(changes, 1);
    expect(controller.items, isEmpty);
  });

  test('unknown totals use per-page metadata to detect the last batch', () async {
    final controller = PaginationController<int>(
      pageSize: 20,
      loadPage: (number, _) async => page(number == 1 ? [1, 2] : [3], perPage: 2),
    );
    addTearDown(controller.dispose);
    await controller.refresh();
    expect(controller.hasMore, isTrue);
    await controller.loadMore();
    expect(controller.hasMore, isFalse);
  });

  testWidgets('a failed initial page is retryable and does not appear as empty success', (tester) async {
    var fail = true;
    final controller = PaginationController<int>(
      loadPage: (_, _) async {
        if (fail) throw StateError('failed');
        return page([], total: 0);
      },
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedListView<int>(controller: controller, itemBuilder: (_, item, _) => Text('$item')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('加载失败，请重试'), findsOneWidget);
    expect(find.text('暂无数据'), findsNothing);
    fail = false;
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();
    expect(find.text('暂无数据'), findsOneWidget);
    expect(controller.initialized, isTrue);
  });

  testWidgets('a list detaches but never disposes an external controller', (tester) async {
    final controller = PaginationController<int>(loadPage: (_, _) async => page([1], total: 1));
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PagedListView<int>(controller: controller, itemBuilder: (_, item, _) => Text('$item')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await controller.refresh();
    expect(controller.items, [1]);
  });

  testWidgets('disabling load preserves the scrollable and its position', (tester) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    late StateSetter rebuild;
    var enabled = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (_, setState) {
              rebuild = setState;
              return AppEasyRefresh(
                enableLoad: enabled,
                onLoad: () async {},
                childBuilder: (_, physics) => ListView.builder(
                  controller: scroll,
                  physics: physics,
                  itemCount: 100,
                  itemBuilder: (_, index) => SizedBox(height: 60, child: Text('row $index')),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    final state = tester.state<ScrollableState>(find.byType(Scrollable));
    final offset = scroll.offset;
    rebuild(() => enabled = false);
    await tester.pumpAndSettle();
    expect(identical(tester.state<ScrollableState>(find.byType(Scrollable)), state), isTrue);
    expect(scroll.offset, offset);
  });

  for (final nested in [false, true]) {
    testWidgets('locator refresh supports ${nested ? 'nested' : 'sliver'} scrolling while disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEasyRefresh(
              useLocator: true,
              enableRefresh: false,
              enableLoad: false,
              childBuilder: (_, physics) {
                final body = CustomScrollView(
                  physics: physics,
                  slivers: [
                    if (!nested) const HeaderLocator.sliver(clearExtent: false),
                    SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      delegate: SliverChildBuilderDelegate((_, index) => Text('item $index'), childCount: 20),
                    ),
                    const FooterLocator.sliver(),
                  ],
                );
                return nested
                    ? NestedScrollView(
                        physics: physics,
                        headerSliverBuilder: (_, _) => [const HeaderLocator.sliver(clearExtent: false)],
                        body: body,
                      )
                    : body;
              },
            ),
          ),
        ),
      );
      await tester.drag(find.byType(CustomScrollView).last, const Offset(0, 150));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
