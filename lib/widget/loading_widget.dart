import 'package:app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class LoadingWidgetController extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setIsLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}

class LoadingWidget extends StatelessWidget {
  final LoadingWidgetController controller;
  final Widget child;

  const LoadingWidget({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          children: [
            child,
            if (controller.isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 每次显示返回独立、可重复调用的关闭函数，适用于并行请求。
VoidCallback showAppLoading(OverlayState overlay) {
  final entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.08),
          child: Center(
            child: Semantics(
              label: context.l10n.loading,
              child: const CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    ),
  );
  var closed = false;
  overlay.insert(entry);
  return () {
    if (closed) return;
    closed = true;
    entry.remove();
    entry.dispose();
  };
}
