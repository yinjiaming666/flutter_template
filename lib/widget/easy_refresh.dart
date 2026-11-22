import 'package:app/widget/app_easy_refresh.dart';
import 'package:flutter/material.dart';

/// 兼容原有外部列表写法。onLoad 必须返回“本页条数”，失败时抛出异常。
/// 新页面需要类型化数据和旧请求保护时，使用 PaginationController / PagedListView。
class EasyRefreshWidget extends StatefulWidget {
  const EasyRefreshWidget({super.key, required this.onLoad, required this.itemBuilder, this.pageSize = 20})
    : assert(pageSize > 0);

  final Future<int> Function(int page, int pageSize) onLoad;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int pageSize;

  @override
  State<EasyRefreshWidget> createState() => _EasyRefreshWidgetState();
}

class _EasyRefreshWidgetState extends State<EasyRefreshWidget> {
  int _page = 0;
  int _count = 0;
  bool _hasMore = true;

  Future<IndicatorResult> _request({required bool refresh}) async {
    if (!refresh && !_hasMore) return IndicatorResult.noMore;
    final nextPage = refresh ? 1 : _page + 1;
    try {
      final count = await widget.onLoad(nextPage, widget.pageSize);
      if (!mounted) return IndicatorResult.fail;
      if (count < 0) throw StateError('本页条数不能为负数');
      setState(() {
        _page = nextPage;
        _hasMore = count >= widget.pageSize;
        _count = (refresh ? 0 : _count) + count;
      });
      return !refresh && count < widget.pageSize ? IndicatorResult.noMore : IndicatorResult.success;
    } catch (_) {
      return IndicatorResult.fail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppEasyRefresh(
      refreshOnStart: true,
      onRefresh: () => _request(refresh: true),
      onLoad: () => _request(refresh: false),
      childBuilder: (context, physics) =>
          ListView.builder(physics: physics, itemCount: _count, itemBuilder: widget.itemBuilder),
    );
  }
}
