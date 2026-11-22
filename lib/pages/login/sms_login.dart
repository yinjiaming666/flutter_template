import 'dart:async';

import 'package:app/l10n/l10n.dart';
import 'package:app/router.dart' show AppRoute;
import 'package:app/tool/toast_helper.dart';
import 'package:app/widget/app_language_button.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:app/widget/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmsLoginPage extends BasePage {
  const SmsLoginPage({super.key});

  @override
  BasePageState<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends BasePageState<SmsLoginPage> {
  late final TextEditingController _accountController;

  @override
  bool get useSafeArea => false;

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
      ToastHelper.showToast(msg: context.l10n.enterAccount);
      return;
    }
    unawaited(pushPage<void>(AppRoute.home, clearStack: true));
  }

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(
    title: Text(context.l10n.login),
    actions: const [AppLanguageButton()],
  );

  @override
  Widget buildPageBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 80.w),
          CommonWidget.textInput(
            _accountController,
            hintText: context.l10n.enterAccount,
            height: 48.w,
          ),
          SizedBox(height: 24.w),
          GestureDetector(
            onTap: _login,
            child: CommonWidget.btn(
              height: 48.w,
              text: context.l10n.openTemplateHome,
              borderRadius: 24.w,
            ),
          ),
        ],
      ),
    );
  }
}
