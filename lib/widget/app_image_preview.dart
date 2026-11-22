import 'dart:async';

import 'package:app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class AppImagePreview extends StatefulWidget {
  const AppImagePreview._({required this.images, required this.initialIndex});

  final List<ImageProvider<Object>> images;
  final int initialIndex;

  /// Displays local, bundled or remote images using their existing providers.
  static Future<void> show(
    BuildContext context, {
    required List<ImageProvider<Object>> images,
    int initialIndex = 0,
    bool useRootNavigator = true,
  }) async {
    if (!context.mounted || images.isEmpty) return;
    RangeError.checkValidIndex(initialIndex, images, 'initialIndex');
    final items = List<ImageProvider<Object>>.unmodifiable(images);
    await Navigator.of(context, rootNavigator: useRootNavigator).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            AppImagePreview._(images: items, initialIndex: initialIndex),
      ),
    );
  }

  @override
  State<AppImagePreview> createState() => _AppImagePreviewState();
}

class _AppImagePreviewState extends State<AppImagePreview> {
  late final _pageController = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  bool _zoomed = false;
  bool _dragging = false;
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    _precacheNeighbors();
  }

  void _precacheNeighbors() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final index in [_index - 1, _index + 1]) {
        if (index >= 0 && index < widget.images.length) {
          unawaited(
            precacheImage(widget.images[index], context, onError: (_, _) {}),
          );
        }
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
      _zoomed = false;
    });
    _precacheNeighbors();
  }

  void _onZoomChanged(bool zoomed) {
    setState(() {
      _zoomed = zoomed;
      _dragging = false;
      _drag = 0;
    });
  }

  void _endDrag(DragEndDetails details) {
    if (!_zoomed &&
        (_drag >= 0.2 ||
            (_drag > 0.025 && (details.primaryVelocity ?? 0) > 700))) {
      _close();
    } else {
      _resetDrag();
    }
  }

  void _resetDrag() {
    setState(() {
      _dragging = false;
      _drag = 0;
    });
  }

  void _close() {
    if (ModalRoute.of(context)?.isCurrent == true) Navigator.of(context).pop();
  }

  void _move(int index) {
    if (!_pageController.hasClients) return;
    unawaited(
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = widget.images.length;
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: l10n.close,
              onPressed: _close,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => GestureDetector(
                    onVerticalDragStart: _zoomed
                        ? null
                        : (_) => setState(() => _dragging = true),
                    onVerticalDragUpdate: _zoomed
                        ? null
                        : (details) {
                            if (constraints.maxHeight <= 0) return;
                            setState(
                              () => _drag =
                                  (_drag +
                                          details.delta.dy /
                                              constraints.maxHeight)
                                      .clamp(0.0, 1.0),
                            );
                          },
                    onVerticalDragEnd: _zoomed ? null : _endDrag,
                    onVerticalDragCancel: _zoomed ? null : _resetDrag,
                    child: AnimatedSlide(
                      offset: Offset(0, _drag),
                      duration: _dragging
                          ? Duration.zero
                          : const Duration(milliseconds: 160),
                      child: PageView.builder(
                        controller: _pageController,
                        physics: _zoomed
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        onPageChanged: _onPageChanged,
                        itemCount: count,
                        itemBuilder: (context, index) => _ZoomableImage(
                          image: widget.images[index],
                          active: index == _index,
                          onZoomChanged: _onZoomChanged,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (count > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: l10n.previousImage,
                      onPressed: _index > 0 ? () => _move(_index - 1) : null,
                      icon: const BackButtonIcon(),
                    ),
                    Text(l10n.imagePosition(_index + 1, count)),
                    IconButton(
                      tooltip: l10n.nextImage,
                      onPressed: _index + 1 < count
                          ? () => _move(_index + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({
    required this.image,
    required this.active,
    required this.onZoomChanged,
  });

  final ImageProvider<Object> image;
  final bool active;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _transform = TransformationController();
  Offset _tap = Offset.zero;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
  }

  @override
  void didUpdateWidget(_ZoomableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active && !widget.active) {
      _transform.value = Matrix4.identity();
    }
  }

  void _onTransform() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.001;
    if (zoomed == _zoomed) return;
    _zoomed = zoomed;
    if (widget.active) widget.onZoomChanged(zoomed);
  }

  void _doubleTap() {
    if (_zoomed) {
      _transform.value = Matrix4.identity();
      return;
    }
    const scale = 2.5;
    _transform.value = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(_tap.dx * (1 - scale), _tap.dy * (1 - scale), 0);
  }

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onDoubleTapDown: (details) => _tap = details.localPosition,
    onDoubleTap: _doubleTap,
    child: InteractiveViewer(
      alignment: Alignment.topLeft,
      transformationController: _transform,
      maxScale: 4,
      child: SizedBox.expand(
        child: Image(
          image: widget.image,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => Center(
            child: Icon(
              Icons.broken_image_outlined,
              semanticLabel: context.l10n.imageLoadFailed,
            ),
          ),
        ),
      ),
    ),
  );
}
