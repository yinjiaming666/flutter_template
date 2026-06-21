import 'package:app/router.dart';
import 'package:app/tool/route_helper.dart';
import 'package:app/tool/toast_helper.dart';
import 'package:app/widget/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmsLoginPage extends StatefulWidget {
  const SmsLoginPage({super.key});

  @override
  State<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> {
  late final TextEditingController _accountController;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController();
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  void _login() {
    if (_accountController.text.trim().isEmpty) {
      ToastHelper.showToast(msg: '请输入账号');
      return;
    }
    RouterHelper.switchTab(Routes.indexPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 80.w),
            CommonWidget.textInput(
              _accountController,
              hintText: '请输入账号',
              height: 48.w,
            ),
            SizedBox(height: 24.w),
            GestureDetector(
              onTap: _login,
              child: CommonWidget.btn(
                height: 48.w,
                text: '进入模板首页',
                borderRadius: 24.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
