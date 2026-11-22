import 'package:app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// 为骨架布局提供主题颜色，并屏蔽占位内容的点击、焦点和朗读。
///
/// child 使用 SkeletonBox 等组件描述占位布局，不发起请求或管理滚动。
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    required this.child,
    this.color,
    this.semanticsLabel,
  });

  final Widget child;
  final Color? color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return _SkeletonScope(
      color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Semantics(
        container: true,
        liveRegion: true,
        label: semanticsLabel ?? context.l10n.loading,
        child: ExcludeSemantics(
          child: ExcludeFocus(child: IgnorePointer(child: child)),
        ),
      ),
    );
  }
}

/// 不绑定业务样式的矩形或圆形骨架占位。
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  }) : assert(width == null || width >= 0),
       assert(height >= 0);

  const SkeletonBox.circle({super.key, double size = 40})
    : assert(size >= 0),
      width = size,
      height = size,
      borderRadius = const BorderRadius.all(Radius.circular(9999));

  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color color =
        context.dependOnInheritedWidgetOfExactType<_SkeletonScope>()?.color ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      ),
    );
  }
}

class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({required this.color, required super.child});

  final Color color;

  @override
  bool updateShouldNotify(_SkeletonScope oldWidget) => color != oldWidget.color;
}
