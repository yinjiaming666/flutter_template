import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class EasyRefreshWidget extends StatefulWidget {
  final Future<int> Function(int page, int pageSize) onLoad;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int pageSize;

  const EasyRefreshWidget({
    super.key,
    required this.onLoad,
    required this.itemBuilder,
    this.pageSize = 20,
  });

  @override
  State<EasyRefreshWidget> createState() => _EasyRefreshWidgetState();
}

class _EasyRefreshWidgetState extends State<EasyRefreshWidget> {
  final EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  int _page = 1;
  int _count = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _page = 1;
    _count = await widget.onLoad(_page, widget.pageSize);
    _controller.finishRefresh();
    _controller.resetFooter();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _load() async {
    _page++;
    _count = await widget.onLoad(_page, widget.pageSize);
    _controller.finishLoad(
      _count < widget.pageSize
          ? IndicatorResult.noMore
          : IndicatorResult.success,
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: _controller,
      onRefresh: _refresh,
      onLoad: _load,
      child: ListView.builder(
        itemCount: _count,
        itemBuilder: widget.itemBuilder,
      ),
    );
  }
}
