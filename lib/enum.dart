enum CacheKeys { token, userinfo }

extension CacheKeysExtension on CacheKeys {
  String get val {
    switch (this) {
      case CacheKeys.token:
        return 'token';
      case CacheKeys.userinfo:
        return 'userinfo';
    }
  }
}

enum HttpRespCode { success, fail, needLogin, error, notFound }

extension RespStatusExtension on HttpRespCode {
  int get val {
    switch (this) {
      case HttpRespCode.success:
        return 1;
      case HttpRespCode.fail:
        return 0;
      case HttpRespCode.needLogin:
        return 401;
      case HttpRespCode.error:
        return 500;
      case HttpRespCode.notFound:
        return 404;
    }
  }
}
