import 'package:app/config.dart';
import 'package:app/enum.dart';
import 'package:app/main.dart';
import 'package:app/router.dart';
import 'package:app/tool/route_helper.dart';
import 'package:app/tool/toast_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Request {
  final Dio dio = Dio();
  final CancelToken token = CancelToken();

  Request() {
    dio.options
      ..baseUrl = Config.serverUrl
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..validateStatus = (int? status) => status != null && status > 0;

    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.statusCode == HttpRespCode.error.val) {
            ToastHelper.showToast(msg: '服务器异常', channel: 'error');
            return;
          }
          if (response.statusCode == HttpRespCode.notFound.val) {
            ToastHelper.showToast(msg: '接口不存在', channel: 'error');
            return;
          }
          if (response.data is Map &&
              response.data['code'] == HttpRespCode.needLogin.val) {
            ToastHelper.showToast(
              msg: response.data['msg']?.toString() ?? '请登录',
              channel: 'needLogin',
            );
            RouterHelper.pushWithNoContext(Routes.loginPage, clearStack: true);
            return;
          }
          return handler.next(response);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Options? opts,
    Object? data,
    CancelToken? t,
    bool showLoading = false,
    BuildContext? context,
  }) async {
    final String requestPath = '${Config.apiPrefix}$path';
    final Options options =
        opts ??
        Options(contentType: Headers.jsonContentType, headers: _headers());
    final Response response = await dio.post(
      requestPath,
      data: data,
      options: options,
      cancelToken: t ?? token,
    );
    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Options? opts,
    Map<String, dynamic>? data,
    CancelToken? t,
    bool showLoading = false,
    BuildContext? context,
  }) async {
    final String requestPath = '${Config.apiPrefix}$path';
    final Options options =
        opts ??
        Options(contentType: Headers.jsonContentType, headers: _headers());
    final Response response = await dio.get(
      requestPath,
      queryParameters: data,
      options: options,
      cancelToken: t ?? token,
    );
    return _normalizeResponse(response.data);
  }

  Map<String, dynamic> _headers() {
    final String token =
        sharedPreferencesInstance.getString(CacheKeys.token.val) ?? '';
    return {'Token': token};
  }

  Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{
      'code': HttpRespCode.fail.val,
      'msg': '响应格式错误',
      'data': data,
    };
  }
}
