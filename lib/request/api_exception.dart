/// 已收到服务端响应，但业务操作失败。
class ApiException implements Exception {
  const ApiException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}
