import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    return _preferences?.setString(key, value) ?? Future.value(false);
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    return _preferences?.setInt(key, value) ?? Future.value(false);
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return _preferences?.setBool(key, value) ?? Future.value(false);
  }

  Future<bool> remove(String key) async {
    return _preferences?.remove(key) ?? Future.value(false);
  }

  Future<bool> clear() async {
    return _preferences?.clear() ?? Future.value(false);
  }
}
