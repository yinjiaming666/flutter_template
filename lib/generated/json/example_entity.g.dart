import 'package:app/generated/json/base/json_convert_content.dart';
import 'package:app/model/response/example_entity.dart';

ExampleEntity $ExampleEntityFromJson(Map<String, dynamic> json) {
  final ExampleEntity exampleEntity = ExampleEntity();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    exampleEntity.id = id;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    exampleEntity.title = title;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    exampleEntity.description = description;
  }
  final int? createTime = jsonConvert.convert<int>(json['create_time']);
  if (createTime != null) {
    exampleEntity.createTime = createTime;
  }
  return exampleEntity;
}

Map<String, dynamic> $ExampleEntityToJson(ExampleEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['title'] = entity.title;
  data['description'] = entity.description;
  data['create_time'] = entity.createTime;
  return data;
}

extension ExampleEntityExtension on ExampleEntity {
  ExampleEntity copyWith({
    int? id,
    String? title,
    String? description,
    int? createTime,
  }) {
    return ExampleEntity()
      ..id = id ?? this.id
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..createTime = createTime ?? this.createTime;
  }
}
