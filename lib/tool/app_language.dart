import 'package:app/enum.dart';
import 'package:app/tool/shared_preferences.dart';
import 'package:flutter/widgets.dart';

enum AppLanguage {
  system(null),
  chinese(Locale('zh')),
  english(Locale('en'));

  const AppLanguage(this.locale);

  final Locale? locale;
}

class AppLanguageController extends ChangeNotifier {
  AppLanguageController(this._preferences)
    : _language = switch (_preferences.getString(CacheKeys.appLanguage.val)) {
        'zh' => AppLanguage.chinese,
        'en' => AppLanguage.english,
        _ => AppLanguage.system,
      };

  final SharedPreferencesHelper _preferences;
  AppLanguage _language;
  Future<void> _writes = Future<void>.value();

  AppLanguage get language => _language;

  Future<bool> select(AppLanguage language) {
    final result = _writes.then((_) async {
      if (_language == language) return true;
      final key = CacheKeys.appLanguage.val;
      final code = language.locale?.languageCode;
      final saved = code == null
          ? await _preferences.remove(key)
          : await _preferences.setString(key, code);
      if (saved) {
        _language = language;
        notifyListeners();
      }
      return saved;
    });
    _writes = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }
}
