import 'dart:math' as math;

import 'package:app/l10n/l10n.dart';
import 'package:app/widget/app_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

export 'package:image_picker/image_picker.dart' show XFile;

enum AppMediaKind { image, video }

enum AppMediaFilter { images, videos, all }

enum AppMediaSource { gallery, cameraImage, cameraVideo }

class PickedMedia {
  const PickedMedia({required this.file, required this.kind, this.source});

  final XFile file;
  final AppMediaKind kind;

  /// The original source may be unavailable after Android process recreation.
  final AppMediaSource? source;
}

abstract final class AppMediaPicker {
  static final _picker = ImagePicker();
  static bool _busy = false;

  /// Opens a source menu followed by the system picker. Canceling returns null.
  static Future<List<PickedMedia>?> show(
    BuildContext context, {
    AppMediaFilter filter = AppMediaFilter.images,
    int maxItems = 1,
    AppMediaSource? source,
    Duration? maxCameraVideoDuration,
  }) async {
    if (maxItems < 1) throw RangeError.range(maxItems, 1, null, 'maxItems');
    if (!context.mounted || _busy) return null;
    _busy = true;
    try {
      FocusScope.of(context).unfocus();
      final l10n = context.l10n;
      final cameraSupported = _picker.supportsImageSource(ImageSource.camera);
      final sources = [
        if (cameraSupported && filter != AppMediaFilter.videos)
          AppAction(value: AppMediaSource.cameraImage, label: l10n.takePhoto),
        if (cameraSupported && filter != AppMediaFilter.images)
          AppAction(value: AppMediaSource.cameraVideo, label: l10n.recordVideo),
        AppAction(value: AppMediaSource.gallery, label: l10n.chooseGallery),
      ];
      if (source != null && !sources.any((option) => option.value == source)) {
        throw ArgumentError.value(
          source,
          'source',
          'Unavailable for this platform or media filter',
        );
      }
      final selected =
          source ??
          (sources.length == 1
              ? sources.single.value
              : await showAppActionSheet(
                  context,
                  actions: sources,
                  title: l10n.mediaSource,
                  cancelText: l10n.cancel,
                ));
      if (!context.mounted || selected == null) return null;
      if (selected != AppMediaSource.gallery) {
        final isVideo = selected == AppMediaSource.cameraVideo;
        final file = isVideo
            ? await _picker.pickVideo(
                source: ImageSource.camera,
                maxDuration: maxCameraVideoDuration,
              )
            : await _picker.pickImage(
                source: ImageSource.camera,
                requestFullMetadata: false,
              );
        if (file == null) return null;
        return [
          PickedMedia(
            file: file,
            kind: isVideo ? AppMediaKind.video : AppMediaKind.image,
            source: selected,
          ),
        ];
      }
      final files = await _pickFromGallery(filter, maxItems);
      if (files.isEmpty) return null;
      final kind = switch (filter) {
        AppMediaFilter.images => AppMediaKind.image,
        AppMediaFilter.videos => AppMediaKind.video,
        AppMediaFilter.all => null,
      };
      return List.unmodifiable(
        await Future.wait([
          for (final file in files.take(maxItems))
            _result(file, kind: kind, source: selected),
        ]),
      );
    } finally {
      _busy = false;
    }
  }

  static Future<List<XFile>> _pickFromGallery(
    AppMediaFilter filter,
    int maxItems,
  ) async {
    if (maxItems > 1) {
      return switch (filter) {
        AppMediaFilter.images => _picker.pickMultiImage(
          limit: maxItems,
          requestFullMetadata: false,
        ),
        AppMediaFilter.videos => _picker.pickMultiVideo(limit: maxItems),
        AppMediaFilter.all => _picker.pickMultipleMedia(
          limit: maxItems,
          requestFullMetadata: false,
        ),
      };
    }
    final file = await switch (filter) {
      AppMediaFilter.images => _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      ),
      AppMediaFilter.videos => _picker.pickVideo(source: ImageSource.gallery),
      AppMediaFilter.all => _picker.pickMedia(requestFullMetadata: false),
    };
    return [if (file != null) file];
  }

  /// Reads the result after Android recreates the process during a selection.
  static Future<List<PickedMedia>> recoverLostMedia() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android || _busy) {
      return const [];
    }
    _busy = true;
    try {
      final result = await _picker.retrieveLostData();
      if (result.exception case final error?) throw error;
      final files = result.files ?? const <XFile>[];
      return List.unmodifiable(
        await Future.wait(files.map((file) => _result(file))),
      );
    } finally {
      _busy = false;
    }
  }

  static Future<PickedMedia> _result(
    XFile file, {
    AppMediaKind? kind,
    AppMediaSource? source,
  }) async {
    var resolvedKind =
        kind ??
        _kindForMimeType(file.mimeType) ??
        _kindForMimeType(lookupMimeType(file.name)) ??
        _kindForMimeType(lookupMimeType(file.path));
    if (resolvedKind == null) {
      final sampleSize = math.min(
        await file.length(),
        defaultMagicNumbersMaxLength,
      );
      final header = await file
          .openRead(0, sampleSize)
          .expand((chunk) => chunk)
          .toList();
      resolvedKind = _kindForMimeType(
        lookupMimeType(file.name, headerBytes: header),
      );
    }
    if (resolvedKind == null) {
      throw const FormatException('Unrecognized media type');
    }
    return PickedMedia(file: file, kind: resolvedKind, source: source);
  }

  static AppMediaKind? _kindForMimeType(String? value) {
    final type = value?.toLowerCase();
    if (type?.startsWith('image/') == true) return AppMediaKind.image;
    if (type?.startsWith('video/') == true) return AppMediaKind.video;
    return null;
  }
}
