import 'dart:convert';

import 'package:app/generated/json/base/json_field.dart';
import 'package:app/generated/json/example_entity.g.dart';

@JsonSerializable()
class ExampleEntity {
  int id = 0;
  String title = '';
  String description = '';
  @JSONField(name: 'create_time')
  int createTime = 0;

  ExampleEntity();

  factory ExampleEntity.fromJson(Map<String, dynamic> json) =>
      $ExampleEntityFromJson(json);

  Map<String, dynamic> toJson() => $ExampleEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
