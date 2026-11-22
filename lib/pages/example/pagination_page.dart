import 'dart:async';
import 'dart:math' as math;

import 'package:app/l10n/l10n.dart';
import 'package:app/model/response/page_resp_entity.dart';
import 'package:app/request/api_exception.dart';
import 'package:app/tool/pagination_controller.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:app/widget/paged_list_view.dart';
import 'package:flutter/material.dart';

class PaginationExample extends BasePage {
  const PaginationExample({super.key});

  @override
  BasePageState<PaginationExample> createState() => _PaginationExampleState();
}

class _PaginationExampleState extends BasePageState<PaginationExample> {
  late final PaginationController<int> _controller;
  bool _empty = false;
  bool _failNext = false;

  @override
  void initState() {
    super.initState();
    _controller = PaginationController(
      loadPage: _loadPage,
      pageSize: 10,
      itemKey: (item) => item,
    );
  }

  Future<PageData<int>> _loadPage(int page, int limit) async {
    final failureMessage = context.l10n.simulatedRequestFailed;
    final fail = _failNext;
    final empty = _empty;
    _failNext = false;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (fail) throw ApiException(failureMessage);
    final total = empty ? 0 : 37;
    final start = math.min((page - 1) * limit, total);
    final end = math.min(start + limit, total);
    return PageData<int>()
      ..data = List.generate(end - start, (index) => start + index + 1)
      ..total = total
      ..currentPage = page
      ..perPage = limit
      ..lastPage = (total / limit).ceil();
  }

  void _refresh({required bool empty}) {
    _empty = empty;
    _failNext = false;
    unawaited(_controller.refresh(clear: true));
  }

  void _fail() {
    _failNext = true;
    unawaited(_controller.refresh(force: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) =>
      AppBar(title: Text(context.l10n.paginationExample));

  @override
  Widget buildPageBody(BuildContext context) {
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
                onPressed: () => _refresh(empty: false),
                child: Text(l10n.allData),
              ),
              OutlinedButton(
                onPressed: () => _refresh(empty: true),
                child: Text(l10n.emptyExample),
              ),
              OutlinedButton(
                onPressed: _fail,
                child: Text(l10n.simulateFailure),
              ),
            ],
          ),
        ),
        Expanded(
          child: PagedListView<int>(
            controller: _controller,
            itemBuilder: (context, item, index) =>
                ListTile(title: Text(l10n.exampleItem(item))),
          ),
        ),
      ],
    );
  }
}
