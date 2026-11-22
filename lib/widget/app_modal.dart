import 'package:app/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 统一确认交互；关闭或取消返回 false。
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? cancelText,
  String? confirmText,
  bool isDestructive = false,
  bool useRootNavigator = true,
}) async {
  var closing = false;
  final result = await showCupertinoDialog<bool>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (dialogContext) {
      void close(bool value) {
        if (closing || !(ModalRoute.of(dialogContext)?.isCurrent ?? false)) {
          return;
        }
        closing = true;
        Navigator.of(dialogContext).pop(value);
      }

      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => close(false),
            child: Text(cancelText ?? dialogContext.l10n.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () => close(true),
            child: Text(confirmText ?? dialogContext.l10n.confirm),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// 菜单仅返回选择值，业务操作由调用方执行。
class AppAction<T> {
  const AppAction({
    required this.value,
    required this.label,
    this.enabled = true,
    this.isDestructive = false,
  });

  final T value;
  final String label;
  final bool enabled;
  final bool isDestructive;
}

Future<T?> showAppActionSheet<T>(
  BuildContext context, {
  required List<AppAction<T>> actions,
  String? title,
  String? message,
  String? cancelText,
  bool useRootNavigator = true,
}) {
  var closing = false;
  return showCupertinoModalPopup<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (sheetContext) {
      void close([T? value]) {
        if (closing || !(ModalRoute.of(sheetContext)?.isCurrent ?? false)) {
          return;
        }
        closing = true;
        Navigator.of(sheetContext).pop(value);
      }

      return CupertinoActionSheet(
        title: title == null ? null : Text(title),
        message: message == null ? null : Text(message),
        actions: [
          for (final action in actions)
            Semantics(
              enabled: action.enabled,
              child: IgnorePointer(
                ignoring: !action.enabled,
                child: Opacity(
                  opacity: action.enabled ? 1 : 0.38,
                  child: CupertinoActionSheetAction(
                    onPressed: () => close(action.value),
                    isDestructiveAction: action.isDestructive,
                    child: Text(action.label),
                  ),
                ),
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => close(),
          child: Text(cancelText ?? sheetContext.l10n.cancel),
        ),
      );
    },
  );
}

/// 通用底部层只统一安全区、键盘避让和返回值，样式交给当前主题。
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool avoidKeyboard = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (sheetContext) => AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: avoidKeyboard
            ? MediaQuery.viewInsetsOf(sheetContext).bottom
            : 0,
      ),
      duration: const Duration(milliseconds: 150),
      child: SafeArea(top: false, child: builder(sheetContext)),
    ),
  );
}
