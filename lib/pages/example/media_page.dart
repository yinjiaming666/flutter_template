import 'dart:async';
import 'dart:io';

import 'package:app/l10n/l10n.dart';
import 'package:app/tool/permission.dart';
import 'package:app/widget/app_image_preview.dart';
import 'package:app/widget/app_media_picker.dart';
import 'package:app/widget/base_page_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MediaExamplePage extends BasePage {
  const MediaExamplePage({super.key});

  @override
  BasePageState<MediaExamplePage> createState() => _MediaExamplePageState();
}

class _MediaExamplePageState extends BasePageState<MediaExamplePage> {
  final _mobile =
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  late final AppLifecycleListener _lifecycle;
  List<PickedMedia> _media = const [];
  PermissionStatus? _cameraStatus;
  bool _picking = false;
  bool _checkingPermission = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => _checkPermission());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_checkPermission());
      unawaited(_restoreMedia());
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _restoreMedia() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    setState(() => _picking = true);
    try {
      final result = await AppMediaPicker.recoverLostMedia();
      if (mounted && result.isNotEmpty) setState(() => _media = result);
    } catch (_) {
      if (mounted) _showMessage(context.l10n.mediaPickFailed);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _pick(AppMediaFilter filter) async {
    setState(() => _picking = true);
    try {
      final result = await AppMediaPicker.show(context, filter: filter, maxItems: 6);
      if (mounted && result != null) setState(() => _media = result);
    } catch (_) {
      if (mounted) _showMessage(context.l10n.mediaPickFailed);
    } finally {
      if (mounted) {
        setState(() => _picking = false);
        unawaited(_checkPermission());
      }
    }
  }

  Future<void> _checkPermission({bool request = false}) async {
    if (!_mobile || _checkingPermission) return;
    setState(() => _checkingPermission = true);
    try {
      final status = request
          ? await PermissionHelper.request(Permission.camera)
          : await PermissionHelper.status(Permission.camera);
      if (mounted) setState(() => _cameraStatus = status);
    } catch (_) {
      if (mounted && request) _showMessage(context.l10n.permissionFailed);
    } finally {
      if (mounted) setState(() => _checkingPermission = false);
    }
  }

  Future<void> _openSettings() async {
    try {
      if (await PermissionHelper.openSettings()) return;
    } catch (_) {
      // The platform may be unable to open this app's settings.
    }
    if (mounted) _showMessage(context.l10n.permissionFailed);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  ImageProvider<Object> _imageFor(XFile file) => kIsWeb ? NetworkImage(file.path) : FileImage(File(file.path));

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(title: Text(context.l10n.mediaExample));

  @override
  Widget buildPageBody(BuildContext context) {
    final l10n = context.l10n;
    final cameraLabel = switch (_cameraStatus) {
      PermissionStatus.granted => l10n.permissionGranted,
      PermissionStatus.denied => l10n.permissionDenied,
      PermissionStatus.permanentlyDenied => l10n.permissionPermanentlyDenied,
      PermissionStatus.restricted => l10n.permissionRestricted,
      PermissionStatus.limited => l10n.permissionLimited,
      PermissionStatus.provisional => l10n.permissionProvisional,
      null => l10n.permissionUnknown,
    };
    final images = [
      for (final item in _media)
        if (item.kind == AppMediaKind.image) _imageFor(item.file),
    ];
    var imageIndex = 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: _picking ? null : () => _pick(AppMediaFilter.images),
              child: Text(l10n.selectPictures),
            ),
            OutlinedButton(
              onPressed: _picking ? null : () => _pick(AppMediaFilter.videos),
              child: Text(l10n.selectVideos),
            ),
            OutlinedButton(onPressed: _picking ? null : () => _pick(AppMediaFilter.all), child: Text(l10n.selectMedia)),
          ],
        ),
        const SizedBox(height: 12),
        if (_media.isEmpty) Text(l10n.noMedia),
        for (final item in _media)
          if (item.kind == AppMediaKind.image)
            _ImageTile(file: item.file, images: images, index: imageIndex++)
          else
            ListTile(leading: const Icon(Icons.movie_outlined), title: Text(item.file.name)),
        if (_mobile) ...[
          const SizedBox(height: 24),
          Text(l10n.cameraPermission, style: Theme.of(context).textTheme.titleMedium),
          Text(cameraLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _checkingPermission || _picking ? null : () => _checkPermission(request: true),
                child: Text(l10n.requestPermission),
              ),
              if (_cameraStatus == PermissionStatus.permanentlyDenied)
                OutlinedButton(onPressed: _openSettings, child: Text(l10n.openSettings)),
            ],
          ),
        ],
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.file, required this.images, required this.index});

  final XFile file;
  final List<ImageProvider<Object>> images;
  final int index;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Image(
      image: ResizeImage.resizeIfNeeded(128, null, images[index]),
      height: 48,
      width: 48,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => const Icon(Icons.broken_image_outlined),
    ),
    title: Text(file.name),
    onTap: () => AppImagePreview.show(context, images: images, initialIndex: index),
  );
}
