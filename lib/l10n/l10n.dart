import 'package:app/l10n/app_localizations.dart';
import 'package:app/l10n/app_localizations_zh.dart';
import 'package:flutter/widgets.dart';

final defaultAppLocalizations = AppLocalizationsZh();

extension AppLocalizationContext on BuildContext {
  /// Widgets embedded in a standalone MaterialApp can use the template's default language.
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? defaultAppLocalizations;
}
