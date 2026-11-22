import 'dart:convert';

import 'package:app/enum.dart';
import 'package:app/tool/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class GlobalAppState extends ChangeNotifier {
  GlobalAppState([this._preferences]);

  final SharedPreferencesHelper? _preferences;
  Future<void> _writes = Future<void>.value();
  String _token = '';
  Map<String, dynamic>? _userinfo;
  int _sessionVersion = 0;
  bool _expiryHandled = false;

  String get token => _token;
  Map<String, dynamic>? get userinfo => _userinfo;
  bool get isLogin => _token.isNotEmpty;
  int get sessionVersion => _sessionVersion;

  /// 在本地缓存初始化后、启动页面前恢复会话。
  void restore() {
    final preferences = _preferences;
    if (preferences == null) return;
    _token = preferences.getString(CacheKeys.token.val) ?? '';
    _userinfo = null;
    final profile = preferences.getString(CacheKeys.userinfo.val);
    if (_token.isNotEmpty && profile != null) {
      try {
        final decoded = jsonDecode(profile);
        if (decoded is Map<String, dynamic>) _userinfo = decoded;
      } on FormatException {
        // 旧资料无法读取时仍可用已有 Token 请求最新资料。
      }
    }
    _sessionVersion++;
    _expiryHandled = false;
    notifyListeners();
  }

  /// 每次登录都开启新会话，包括服务端再次签发相同 Token 的情况。
  Future<void> setToken(String token) {
    final profile = token.isNotEmpty && token == _token ? _userinfo : null;
    _sessionVersion++;
    _expiryHandled = false;
    return _commit(token, profile);
  }

  Future<void> setUserinfo(Map<String, dynamic>? userinfo) =>
      _commit(_token, userinfo);

  Future<void> clear() => setToken('');

  /// 同一会话只处理一次过期。清理期间开始了新会话时，调用方也应跳过提示和跳转。
  Future<bool> expireIfCurrent(int version, String requestToken) async {
    if (version != _sessionVersion ||
        requestToken != _token ||
        _expiryHandled) {
      return false;
    }
    _expiryHandled = true;
    try {
      await _commit('', null);
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'app session',
          context: ErrorDescription('while removing expired credentials'),
        ),
      );
    }
    return version == _sessionVersion;
  }

  Future<void> _commit(String token, Map<String, dynamic>? profile) {
    final encoded = profile == null ? null : jsonEncode(profile);
    _token = token;
    _userinfo = profile;
    // 先排入写入队列再通知页面，防止旧会话的清理覆盖后续登录。
    final result = _writes.then((_) => _persist(token, encoded));
    _writes = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    notifyListeners();
    return result;
  }

  Future<void> _persist(String token, String? profile) async {
    final preferences = _preferences;
    if (preferences == null) return;
    final tokenKey = CacheKeys.token.val;
    final profileKey = CacheKeys.userinfo.val;
    if (token.isEmpty) {
      final removed = await Future.wait([
        preferences.remove(tokenKey),
        preferences.remove(profileKey),
      ]);
      if (removed.contains(false)) {
        throw StateError('Could not remove saved session');
      }
      return;
    }
    // 先移除上一账号的资料，再保存新凭据。写入失败后，下一次提交会重试整个快照。
    if (profile == null || preferences.getString(tokenKey) != token) {
      if (!await preferences.remove(profileKey)) {
        throw StateError('Could not remove saved profile');
      }
    }
    if (!await preferences.setString(tokenKey, token)) {
      throw StateError('Could not save session token');
    }
    if (profile != null && !await preferences.setString(profileKey, profile)) {
      throw StateError('Could not save session profile');
    }
  }
}
