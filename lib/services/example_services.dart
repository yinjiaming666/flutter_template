import 'package:app/enum.dart';
import 'package:app/main.dart' show currentAppLocalizations;
import 'package:app/model/response/example_entity.dart';
import 'package:app/model/response/list_resp_entity.dart';
import 'package:app/model/response/page_resp_entity.dart';
import 'package:app/model/response/resp_entity.dart';
import 'package:app/request/api_exception.dart';
import 'package:app/request/request.dart';
import 'package:app/tool/toast_helper.dart';

class ExampleServices {
  static T _decode<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) decode,
  ) {
    try {
      return decode(json);
    } on FormatException {
      throw ApiException(currentAppLocalizations.responseFormatError);
    }
  }

  static Future<ExampleEntity?> getDetail({
    required int id,
    Request? request,
  }) async {
    final Map<String, dynamic> res = await (request ?? Request()).get(
      '/example/detail',
      data: {'id': id},
    );
    final RespEntity<ExampleEntity> result = _decode(
      res,
      RespEntity<ExampleEntity>.fromJson,
    );
    if (result.code != HttpRespCode.success.val) {
      if (result.code != HttpRespCode.needLogin.val) {
        ToastHelper.showToast(
          msg: result.msg ?? currentAppLocalizations.exampleDetailFailed,
        );
      }
      return null;
    }
    return result.data ??
        (throw ApiException(currentAppLocalizations.responseFormatError));
  }

  static Future<List<ExampleEntity>> getList({
    int type = 0,
    Request? request,
  }) async {
    final Map<String, dynamic> res = await (request ?? Request()).get(
      '/example/list',
      data: {'type': type},
    );
    final ListRespEntity<ExampleEntity> result = _decode(
      res,
      ListRespEntity<ExampleEntity>.fromJson,
    );
    if (result.code != HttpRespCode.success.val) {
      throw ApiException(
        result.msg.isNotEmpty
            ? result.msg
            : currentAppLocalizations.exampleListFailed,
        code: result.code,
      );
    }
    return result.data;
  }

  static Future<PageData<ExampleEntity>> getPage({
    int page = 1,
    int limit = 20,
    Request? request,
  }) async {
    final Map<String, dynamic> res = await (request ?? Request()).get(
      '/example/page',
      data: {'page': page, 'limit': limit},
    );
    final PageRespEntity<ExampleEntity> result = _decode(
      res,
      PageRespEntity<ExampleEntity>.fromJson,
    );
    if (result.code != HttpRespCode.success.val) {
      throw ApiException(
        result.msg ?? currentAppLocalizations.examplePageFailed,
        code: result.code,
      );
    }
    return result.data;
  }
}
