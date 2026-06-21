import 'package:flutter/foundation.dart';

class GlobalAppState extends ChangeNotifier {
  String _token = '';
  Map<String, dynamic>? _userinfo;

  String get token => _token;

  Map<String, dynamic>? get userinfo => _userinfo;

  bool get isLogin => _token.isNotEmpty;

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setUserinfo(Map<String, dynamic>? userinfo) {
    _userinfo = userinfo;
    notifyListeners();
  }

  void clear() {
    _token = '';
    _userinfo = null;
    notifyListeners();
  }
}
