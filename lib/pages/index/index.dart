import 'package:app/enum.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/request/api_exception.dart';
import 'package:app/router.dart' show AppRoute;
import 'package:dio/dio.dart';
import 'package:app/services/example_services.dart';
import 'package:app/tool/toast_helper.dart';
import 'package:app/widget/app_language_button.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:app/widget/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IndexPage extends BasePage {
  const IndexPage({super.key});

  @override
  BasePageState<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends BasePageState<IndexPage> {
  bool _loading = false;

  @override
  bool get useSafeArea => false;

  Future<void> _requestExample() async {
    setState(() {
      _loading = true;
    });
    try {
      final result = await ExampleServices.getDetail(id: 1);
      if (!mounted || result == null) return;
      ToastHelper.showToast(msg: result.title);
    } catch (error) {
      if (!mounted) return;
      if (error is DioException &&
          (CancelToken.isCancel(error) ||
              error.response?.statusCode == HttpRespCode.needLogin.val)) {
        return;
      }
      ToastHelper.showToast(
        msg: error is ApiException ? error.message : context.l10n.requestFailed,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(
    title: Text(context.l10n.homeTitle),
    actions: const [AppLanguageButton()],
  );

  @override
  Widget buildPageBody(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.appTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.w),
          Text(l10n.templateDescription, style: TextStyle(fontSize: 14)),
          SizedBox(height: 24.w),
          GestureDetector(
            onTap: _loading ? null : _requestExample,
            child: CommonWidget.btn(
              height: 44.w,
              text: _loading ? l10n.requesting : l10n.exampleRequest,
              borderRadius: 22.w,
            ),
          ),
          SizedBox(height: 16.w),
          OutlinedButton(
            onPressed: () => pushPage<void>(AppRoute.loadExample),
            child: Text(l10n.loadExample),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => pushPage<void>(AppRoute.widgetsExample),
            child: Text(l10n.commonWidgetsExample),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => pushPage<void>(AppRoute.paginationExample),
            child: Text(l10n.paginationExample),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => pushPage<void>(AppRoute.mediaExample),
            child: Text(l10n.mediaExample),
          ),
        ],
      ),
    );
  }
}
