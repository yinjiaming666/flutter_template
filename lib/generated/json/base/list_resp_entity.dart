import 'package:app/generated/json/base/json_convert_content.dart';
import 'package:app/model/response/list_resp_entity.dart';

ListRespEntity<T> $ListRespEntityFromJson<T>(Map<String, dynamic> json) {
  final ListRespEntity<T> listRespEntity = ListRespEntity<T>();
  final int? code = jsonConvert.convert<int>(json['code']);
  if (code != null) {
    listRespEntity.code = code;
  }
  final String? msg = jsonConvert.convert<String>(json['msg']);
  if (msg != null) {
    listRespEntity.msg = msg;
  }
  final String? time = jsonConvert.convert<String>(json['time']);
  if (time != null) {
    listRespEntity.time = time;
  }
  final List<T>? data = (json['data'] as List<dynamic>?)
      ?.map((e) => jsonConvert.convert<T>(e) as T)
      .toList();
  if (data != null) {
    listRespEntity.data = data;
  }
  return listRespEntity;
}

Map<String, dynamic> $ListRespEntityToJson(ListRespEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['msg'] = entity.msg;
  data['time'] = entity.time;
  data['data'] = entity.data.map(_toJsonValue).toList();
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
