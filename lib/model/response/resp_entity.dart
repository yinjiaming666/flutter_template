import 'dart:convert';

import 'package:app/generated/json/base/resp_entity.base.dart';

class RespEntity<T> {
  int? code;
  T? data;
  String? msg;

  RespEntity();

  factory RespEntity.fromJson(Map<String, dynamic> json) =>
      $RespEntityFromJson<T>(json);

  Map<String, dynamic> toJson() => $RespEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
