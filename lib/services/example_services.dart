import 'package:app/enum.dart';
import 'package:app/model/response/example_entity.dart';
import 'package:app/model/response/list_resp_entity.dart';
import 'package:app/model/response/page_resp_entity.dart';
import 'package:app/model/response/resp_entity.dart';
import 'package:app/request/request.dart';
import 'package:app/tool/toast_helper.dart';

class ExampleServices {
  static Future<ExampleEntity?> getDetail({required int id}) async {
    final Request request = Request();
    final Map<String, dynamic> res = await request.get(
      '/example/detail',
      data: {'id': id},
    );
    final RespEntity<ExampleEntity> result = RespEntity.fromJson(res);
    if (result.code != HttpRespCode.success.val) {
      ToastHelper.showToast(msg: result.msg ?? '获取详情失败');
      return null;
    }
    return result.data;
  }

  static Future<List<ExampleEntity>> getList({int type = 0}) async {
    final Request request = Request();
    final Map<String, dynamic> res = await request.get(
      '/example/list',
      data: {'type': type},
    );
    final ListRespEntity<ExampleEntity> result = ListRespEntity.fromJson(res);
    if (result.code != HttpRespCode.success.val) {
      ToastHelper.showToast(msg: result.msg.isNotEmpty ? result.msg : '获取列表失败');
    }
    return result.data;
  }

  static Future<PageData<ExampleEntity>> getPage({
    int page = 1,
    int limit = 20,
  }) async {
    final Request request = Request();
    final Map<String, dynamic> res = await request.get(
      '/example/page',
      data: {'page': page, 'limit': limit},
    );
    final PageRespEntity<ExampleEntity> result = PageRespEntity.fromJson(res);
    if (result.code != HttpRespCode.success.val) {
      ToastHelper.showToast(msg: result.msg ?? '获取分页失败');
    }
    return result.data;
  }
}
