import 'package:app/generated/json/base/json_convert_content.dart';
import 'package:app/model/response/page_resp_entity.dart';

PageRespEntity<T> $PageRespEntityFromJson<T>(Map<String, dynamic> json) {
  final PageRespEntity<T> pageRespEntity = PageRespEntity<T>();
  final int? code = jsonConvert.convert<int>(json['code']);
  if (code != null) {
    pageRespEntity.code = code;
  }
  final String? msg = jsonConvert.convert<String>(json['msg']);
  if (msg != null) {
    pageRespEntity.msg = msg;
  }
  final PageData<T> data = PageData.fromJson(
    json['data'] is Map<String, dynamic> ? json['data'] : <String, dynamic>{},
  );
  pageRespEntity.data = data;
  return pageRespEntity;
}

Map<String, dynamic> $PageRespEntityToJson(PageRespEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['msg'] = entity.msg;
  data['data'] = entity.data.toJson();
  return data;
}

PageData<T> $PageDataFromJson<T>(Map<String, dynamic> json) {
  final PageData<T> respEntity = PageData<T>();
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    respEntity.total = total;
  }
  final List<T>? data = (json['data'] as List<dynamic>?)
      ?.map((e) => jsonConvert.convert<T>(e) as T)
      .toList();
  if (data != null) {
    respEntity.data = data;
  }
  final int? currentPage = jsonConvert.convert<int>(json['current_page']);
  if (currentPage != null) {
    respEntity.currentPage = currentPage;
  }
  final int? lastPage = jsonConvert.convert<int>(json['last_page']);
  if (lastPage != null) {
    respEntity.lastPage = lastPage;
  }
  final int? perPage = jsonConvert.convert<int>(json['per_page']);
  if (perPage != null) {
    respEntity.perPage = perPage;
  }
  return respEntity;
}

Map<String, dynamic> $PageDataToJson(PageData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data.map(_toJsonValue).toList();
  data['total'] = entity.total;
  data['current_page'] = entity.currentPage;
  data['last_page'] = entity.lastPage;
  data['per_page'] = entity.perPage;
  return data;
}

dynamic _toJsonValue(dynamic value) {
  if (value == null) {
    return null;
  }
  try {
    return value.toJson();
  } catch (_) {
    return value;
  }
}
