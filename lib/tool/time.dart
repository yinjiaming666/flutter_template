String timestamp2Str(int timestamp) {
  if (timestamp <= 0) {
    return '';
  }
  final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return '${date.year}-${_two(date.month)}-${_two(date.day)} ${_two(date.hour)}:${_two(date.minute)}';
}

int time() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

String _two(int value) {
  return value.toString().padLeft(2, '0');
}
