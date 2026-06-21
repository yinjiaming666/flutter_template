import 'dart:convert';

import 'package:app/generated/json/base/list_resp_entity.dart';

class ListRespEntity<T> {
  int code = 0;
  String msg = '';
  String time = '';
  List<T> data = [];

  ListRespEntity();

  factory ListRespEntity.fromJson(Map<String, dynamic> json) =>
      $ListRespEntityFromJson<T>(json);

  Map<String, dynamic> toJson() => $ListRespEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
