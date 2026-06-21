import 'package:app/services/example_services.dart';
import 'package:app/tool/toast_helper.dart';
import 'package:app/widget/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  bool _loading = false;

  Future<void> _requestExample() async {
    setState(() {
      _loading = true;
    });
    final result = await ExampleServices.getDetail(id: 1);
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
    });
    ToastHelper.showToast(msg: result == null ? '示例请求未配置真实后端' : result.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模板首页')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flutter Template',
              style: TextStyle(fontSize: 24.w, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.w),
            Text('已保留通用路由、请求、实体、工具类和组件骨架。', style: TextStyle(fontSize: 14.w)),
            SizedBox(height: 24.w),
            GestureDetector(
              onTap: _loading ? null : _requestExample,
              child: CommonWidget.btn(
                height: 44.w,
                text: _loading ? '请求中...' : '示例请求',
                borderRadius: 22.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
