import 'package:app/l10n/l10n.dart';
import 'package:app/widget/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 确认返回文本，取消返回 null；异步提交失败时保留输入。
Future<String?> showAppInputPopup(
  BuildContext context, {
  required String title,
  String? hintText,
  String initialValue = '',
  List<String> quickReplies = const [],
  int minLines = 1,
  int maxLines = 1,
  int? maxLength,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  bool obscureText = false,
  bool? trimInput,
  bool allowEmpty = false,
  String? Function(String value)? validator,
  Future<bool> Function(String value)? onSubmit,
  String? confirmText,
  String? submitErrorText,
  bool useRootNavigator = true,
}) {
  assert(minLines > 0 && maxLines >= minLines);
  assert(maxLength == null || maxLength > 0);
  assert(!obscureText || maxLines == 1);
  return showAppBottomSheet<String>(
    context,
    useRootNavigator: useRootNavigator,
    // 拖拽和遮罩会直接关闭路由；异步提交使用关闭按钮与系统返回。
    isDismissible: onSubmit == null,
    enableDrag: onSubmit == null,
    builder: (context) => _InputPopup(
      title: title,
      hintText: hintText,
      initialValue: initialValue,
      quickReplies: quickReplies,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      trimInput: trimInput ?? !obscureText,
      allowEmpty: allowEmpty,
      validator: validator,
      onSubmit: onSubmit,
      confirmText: confirmText ?? context.l10n.confirm,
      submitErrorText: submitErrorText ?? context.l10n.submitFailed,
    ),
  );
}

class _InputPopup extends StatefulWidget {
  const _InputPopup({
    required this.title,
    required this.hintText,
    required this.initialValue,
    required this.quickReplies,
    required this.minLines,
    required this.maxLines,
    required this.maxLength,
    required this.keyboardType,
    required this.inputFormatters,
    required this.obscureText,
    required this.trimInput,
    required this.allowEmpty,
    required this.validator,
    required this.onSubmit,
    required this.confirmText,
    required this.submitErrorText,
  });

  final String title;
  final String? hintText;
  final String initialValue;
  final List<String> quickReplies;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool trimInput;
  final bool allowEmpty;
  final String? Function(String value)? validator;
  final Future<bool> Function(String value)? onSubmit;
  final String confirmText;
  final String submitErrorText;

  @override
  State<_InputPopup> createState() => _InputPopupState();
}

class _InputPopupState extends State<_InputPopup> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode();
  String? _error;
  bool _submitting = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _close([String? value]) {
    if (_closing ||
        _submitting ||
        !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    _closing = true;
    Navigator.of(context).pop(value);
  }

  Future<void> _submit() async {
    if (_closing || _submitting) return;
    final value = widget.trimInput ? _controller.text.trim() : _controller.text;
    final String? error;
    if (!widget.allowEmpty && value.isEmpty) {
      error = context.l10n.enterContent;
    } else if (widget.maxLength != null &&
        value.characters.length > widget.maxLength!) {
      error = context.l10n.characterLimit(widget.maxLength!);
    } else {
      error = widget.validator?.call(value);
    }
    if (error != null) {
      setState(() => _error = error);
      _focus.requestFocus();
      return;
    }
    final submit = widget.onSubmit;
    if (submit == null) {
      _close(value);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    var success = false;
    try {
      success = await submit(value);
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (!success) _error = widget.submitErrorText;
    });
    if (success) _close(value);
  }

  void _chooseReply(String text) {
    final oldValue = _controller.value;
    var nextValue = TextEditingValue(text: text);
    for (final formatter
        in widget.inputFormatters ?? const <TextInputFormatter>[]) {
      nextValue = formatter.formatEditUpdate(oldValue, nextValue);
    }
    if (widget.maxLength != null) {
      nextValue = LengthLimitingTextInputFormatter(
        widget.maxLength,
      ).formatEditUpdate(oldValue, nextValue);
    }
    _controller.value = nextValue.copyWith(
      selection: TextSelection.collapsed(offset: nextValue.text.length),
    );
    setState(() => _error = null);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.cancel,
                  onPressed: _submitting ? null : () => _close(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              enabled: !_submitting,
              obscureText: widget.obscureText,
              autocorrect: !widget.obscureText,
              enableSuggestions: !widget.obscureText,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              keyboardType: widget.keyboardType,
              textInputAction: widget.maxLines > 1
                  ? TextInputAction.newline
                  : TextInputAction.done,
              onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                errorText: _error,
                errorMaxLines: 3,
              ),
            ),
            if (widget.quickReplies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final reply in widget.quickReplies)
                    ActionChip(
                      label: Text(reply),
                      onPressed: _submitting ? null : () => _chooseReply(reply),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.confirmText),
            ),
          ],
        ),
      ),
    );
  }
}
