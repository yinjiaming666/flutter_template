import 'dart:async';

import 'package:app/config.dart';
import 'package:app/enum.dart';
import 'package:app/main.dart';
import 'package:app/model/response/response_decoding.dart';
import 'package:app/request/http_log_interceptor.dart';
import 'package:app/router.dart';
import 'package:app/tool/route_helper.dart';
import 'package:app/tool/toast_helper.dart';
import 'package:app/widget/loading_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Request {
  Request({Dio? client}) : dio = client ?? Dio() {
    dio.options
      ..baseUrl = Config.serverUrl
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..validateStatus = (status) =>
          status != null && status >= 200 && status < 300;
    if (kDebugMode &&
        dio.interceptors.whereType<HttpLogInterceptor>().isEmpty) {
      dio.interceptors.add(HttpLogInterceptor(logger));
    }
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          final data = response.data;
          if (response.statusCode == HttpRespCode.needLogin.val ||
              (data is Map &&
                  responseCode(data['code']) == HttpRespCode.needLogin.val)) {
            await _handleUnauthorized(response.requestOptions, data);
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == HttpRespCode.needLogin.val) {
            await _handleUnauthorized(
              error.requestOptions,
              error.response?.data,
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  static const _sessionVersionKey = 'app.request.sessionVersion';
  final Dio dio;
  final CancelToken token = CancelToken();

  Future<void> _handleUnauthorized(RequestOptions options, Object? data) async {
    final version = options.extra[_sessionVersionKey];
    final requestToken = options.headers['Token']?.toString() ?? '';
    final state = globalAppStateInstance;
    if (version is! int ||
        !await state.expireIfCurrent(version, requestToken)) {
      return;
    }
    if (version != state.sessionVersion) return;
    final message = data is Map ? data['msg']?.toString() : null;
    ToastHelper.showToast(
      msg: message?.isNotEmpty == true
          ? message!
          : currentAppLocalizations.signInAgain,
      channel: 'needLogin',
    );
    unawaited(
      RouterHelper.pushWithNoContext<void>(AppRoute.login, clearStack: true),
    );
  }

  Options _options(Options? options) {
    final resolved = options ?? Options();
    final state = globalAppStateInstance;
    return resolved.copyWith(
      contentType: resolved.contentType ?? Headers.jsonContentType,
      headers: <String, dynamic>{'Token': state.token, ...?resolved.headers},
      extra: {...?resolved.extra, _sessionVersionKey: state.sessionVersion},
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Options? opts,
    Object? data,
    CancelToken? t,
    bool showLoading = false,
    BuildContext? context,
  }) => _send(
    path,
    method: 'POST',
    options: opts,
    body: data,
    cancelToken: t,
    showLoading: showLoading,
    context: context,
  );

  Future<Map<String, dynamic>> get(
    String path, {
    Options? opts,
    Map<String, dynamic>? data,
    CancelToken? t,
    bool showLoading = false,
    BuildContext? context,
  }) => _send(
    path,
    method: 'GET',
    options: opts,
    query: data,
    cancelToken: t,
    showLoading: showLoading,
    context: context,
  );

  Future<Map<String, dynamic>> _send(
    String path, {
    required String method,
    Options? options,
    Object? body,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
    required bool showLoading,
    BuildContext? context,
  }) async {
    final overlay = context != null && context.mounted
        ? Overlay.maybeOf(context, rootOverlay: true) ??
              navigatorKey.currentState?.overlay
        : navigatorKey.currentState?.overlay;
    final dismiss = showLoading && overlay != null
        ? showAppLoading(overlay)
        : null;
    try {
      final response = await dio.request<dynamic>(
        '${Config.apiPrefix}$path',
        data: body,
        queryParameters: query,
        options: _options(options).copyWith(method: method),
        cancelToken: cancelToken ?? token,
      );
      return _normalizeResponse(response.data);
    } finally {
      dismiss?.call();
    }
  }

  Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{
      'code': HttpRespCode.fail.val,
      'msg': currentAppLocalizations.responseFormatError,
      'data': data,
    };
  }
}
