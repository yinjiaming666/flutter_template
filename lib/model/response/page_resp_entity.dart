import 'dart:convert';

import 'package:app/generated/json/base/json_field.dart';
import 'package:app/generated/json/base/page_resp_entity.dart';
import 'package:app/model/response/page_data_impl.dart';

class PageRespEntity<T> {
  int? code;
  late PageData<T> data;
  String? msg;

  PageRespEntity();

  factory PageRespEntity.fromJson(Map<String, dynamic> json) =>
      $PageRespEntityFromJson<T>(json);

  Map<String, dynamic> toJson() => $PageRespEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class PageData<T> implements PageDataImpl {
  int total = 0;
  @JSONField(name: 'per_page')
  int perPage = 0;
  @JSONField(name: 'current_page')
  int currentPage = 0;
  @JSONField(name: 'last_page')
  int lastPage = 0;
  List<T> data = [];

  PageData();

  factory PageData.fromJson(Map<String, dynamic> json) =>
      $PageDataFromJson<T>(json);

  Map<String, dynamic> toJson() => $PageDataToJson(this);

  @override
  List getList() {
    return data;
  }

  @override
  int getTotal() {
    return total;
  }
}
