import 'dart:convert';

import 'package:app/generated/json/base/list_resp_entity.dart';
import 'package:app/model/response/response_decoding.dart';

class ListRespEntity<T> {
  int code = 0;
  String msg = '';
  String time = '';
  List<T> data = [];

  ListRespEntity();

  factory ListRespEntity.fromJson(Map<String, dynamic> json) => decodeResponse(
    json,
    $ListRespEntityFromJson<T>,
    acceptsData: (value) => value is List,
  );

  Map<String, dynamic> toJson() => $ListRespEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
