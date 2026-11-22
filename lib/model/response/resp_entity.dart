import 'dart:convert';

import 'package:app/generated/json/base/resp_entity.base.dart';
import 'package:app/model/response/response_decoding.dart';

class RespEntity<T> {
  int? code;
  T? data;
  String? msg;

  RespEntity();

  factory RespEntity.fromJson(Map<String, dynamic> json) =>
      decodeResponse(json, $RespEntityFromJson<T>);

  Map<String, dynamic> toJson() => $RespEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
