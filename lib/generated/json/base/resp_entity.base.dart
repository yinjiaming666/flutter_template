import 'package:app/generated/json/base/json_convert_content.dart';
import 'package:app/model/response/resp_entity.dart';

RespEntity<T> $RespEntityFromJson<T>(Map<String, dynamic> json) {
  final RespEntity<T> respEntity = RespEntity<T>();
  final int? code = jsonConvert.convert<int>(json['code']);
  if (code != null) {
    respEntity.code = code;
  }
  final T? data = jsonConvert.convert<T>(json['data']);
  if (data != null) {
    respEntity.data = data;
  }
  final String? msg = jsonConvert.convert<String>(json['msg']);
  if (msg != null) {
    respEntity.msg = msg;
  }
  return respEntity;
}

Map<String, dynamic> $RespEntityToJson(RespEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['data'] = _toJsonValue(entity.data);
  data['msg'] = entity.msg;
  return data;
}

extension RespEntityExtension on RespEntity {
  RespEntity copyWith({int? code, dynamic data, String? msg}) {
    return RespEntity()
      ..code = code ?? this.code
      ..data = data ?? this.data
      ..msg = msg ?? this.msg;
  }
}

dynamic _toJsonValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is List) {
    return value.map(_toJsonValue).toList();
  }
  try {
    return value.toJson();
  } catch (_) {
    return value;
  }
}
