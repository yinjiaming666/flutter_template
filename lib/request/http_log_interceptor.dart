import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Reports HTTP metadata without recording request headers, query values or bodies.
class HttpLogInterceptor extends Interceptor {
  HttpLogInterceptor(this._logger);

  final Logger _logger;
  final _timings = Expando<Stopwatch>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _timings[options] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.i(_summary(response.requestOptions, response.statusCode));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final summary = _summary(err.requestOptions, err.response?.statusCode);
    _logger.w('$summary type=${err.type.name}');
    handler.next(err);
  }

  String _summary(RequestOptions options, int? statusCode) {
    final timer = _timings[options];
    timer?.stop();
    _timings[options] = null;
    final path = Uri.tryParse(options.path)?.path ?? '/';
    return 'HTTP ${options.method} $path status=${statusCode ?? '-'} duration=${timer?.elapsedMilliseconds ?? 0}ms';
  }
}
