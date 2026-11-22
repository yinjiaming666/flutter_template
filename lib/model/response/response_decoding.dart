import 'package:app/enum.dart';

/// 接受整数和后端常见的整数形式字符串。
int? responseCode(Object? value) {
  if (value is int) return value;
  final number = switch (value) {
    num n => n,
    String text => num.tryParse(text),
    _ => null,
  };
  if (number == null || !number.isFinite || number != number.truncate()) {
    return null;
  }
  return number.toInt();
}

/// 业务失败时只解析 code、msg 等元数据；生成的解析器无需读取未约定的错误 data。
T decodeResponse<T>(
  Map<String, dynamic> json,
  T Function(Map<String, dynamic>) decode, {
  bool Function(Object?)? acceptsData,
  Object? emptyData,
}) {
  final code = responseCode(json['code']);
  if (code == null) {
    throw const FormatException('Expected an integer response code');
  }
  if (code != HttpRespCode.success.val) {
    return decode({...json, 'code': code, 'data': emptyData});
  }
  if (acceptsData != null && !acceptsData(json['data'])) {
    throw const FormatException('Unexpected response data');
  }
  try {
    return decode(json);
  } on TypeError {
    throw const FormatException('Unexpected item in response data');
  }
}
