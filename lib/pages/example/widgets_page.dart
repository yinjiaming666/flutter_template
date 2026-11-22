import 'package:app/l10n/l10n.dart';
import 'package:app/tool/route_helper.dart';
import 'package:app/widget/app_input_popup.dart';
import 'package:app/widget/app_modal.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:flutter/material.dart';

class CommonWidgetsExample extends BasePage {
  const CommonWidgetsExample({super.key});

  @override
  BasePageState<CommonWidgetsExample> createState() =>
      _CommonWidgetsExampleState();
}

class _CommonWidgetsExampleState extends BasePageState<CommonWidgetsExample> {
  String _value = '';

  Future<void> _input({bool asyncSubmit = false}) async {
    final l10n = context.l10n;
    var firstAttempt = true;
    final value = await showAppInputPopup(
      context,
      title: asyncSubmit ? l10n.asyncSubmitTitle : l10n.inputContent,
      initialValue: _value,
      hintText: l10n.enterContent,
      maxLength: 60,
      maxLines: 3,
      quickReplies: [l10n.hello, l10n.contactLater],
      onSubmit: asyncSubmit
          ? (_) async {
              await Future<void>.delayed(const Duration(milliseconds: 400));
              if (firstAttempt) {
                firstAttempt = false;
                return false;
              }
              return true;
            }
          : null,
    );
    if (mounted && value != null) setState(() => _value = value);
  }

  Future<void> _confirm() async {
    final l10n = context.l10n;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.confirmAction,
      message: l10n.confirmExampleMessage,
    );
    if (mounted && confirmed) setState(() => _value = context.l10n.confirmed);
  }

  Future<void> _actions() async {
    final l10n = context.l10n;
    final action = await showAppActionSheet<String>(
      context,
      title: l10n.chooseAction,
      actions: [
        AppAction(value: 'edit', label: l10n.editContent),
        AppAction(
          value: 'unavailable',
          label: l10n.disabledAction,
          enabled: false,
        ),
        AppAction(
          value: 'clear',
          label: l10n.clearContent,
          isDestructive: true,
        ),
      ],
    );
    if (!mounted) return;
    if (action == 'edit') await _input();
    if (action == 'clear') setState(() => _value = '');
  }

  Future<void> _sheet() => showAppBottomSheet<void>(
    context,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            sheetContext.l10n.customBottomContent,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => RouterHelper.back(context: sheetContext),
            child: Text(sheetContext.l10n.close),
          ),
        ],
      ),
    ),
  );

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) =>
      AppBar(title: Text(context.l10n.commonWidgetsExample));

  @override
  Widget buildPageBody(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_value.isEmpty ? l10n.noInputYet : _value),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: () => _input(),
              child: Text(l10n.inputText),
            ),
            OutlinedButton(
              onPressed: () => _input(asyncSubmit: true),
              child: Text(l10n.asyncSubmit),
            ),
            OutlinedButton(
              onPressed: _confirm,
              child: Text(l10n.confirmDialog),
            ),
            OutlinedButton(onPressed: _actions, child: Text(l10n.actionMenu)),
            OutlinedButton(onPressed: _sheet, child: Text(l10n.bottomSheet)),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.asyncSubmitHint),
      ],
    );
  }
}
