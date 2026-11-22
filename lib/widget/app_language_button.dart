import 'package:app/l10n/l10n.dart';
import 'package:app/tool/app_language.dart';
import 'package:app/widget/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppLanguageButton extends StatelessWidget {
  const AppLanguageButton({super.key});

  Future<void> _chooseLanguage(BuildContext context) async {
    final controller = context.read<AppLanguageController>();
    final l10n = context.l10n;
    final options = {
      AppLanguage.system: l10n.followSystem,
      AppLanguage.chinese: l10n.chineseLanguage,
      AppLanguage.english: l10n.englishLanguage,
    };
    final language = await showAppActionSheet<AppLanguage>(
      context,
      title: l10n.language,
      actions: [
        for (final option in options.entries)
          AppAction(
            value: option.key,
            label: option.value,
            enabled: option.key != controller.language,
          ),
      ],
    );
    if (language == null || !context.mounted) return;
    try {
      if (await controller.select(language)) return;
    } catch (_) {
      // Keep the current language when storage is unavailable.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.languageSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.language,
    icon: const Icon(Icons.language),
    onPressed: () => _chooseLanguage(context),
  );
}
