import 'package:permission_handler/permission_handler.dart';

export 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionStatus;

abstract final class PermissionHelper {
  static final _requests = <Permission, Future<PermissionStatus>>{};
  static Future<void> _queue = Future<void>.value();

  static Future<PermissionStatus> status(Permission permission) =>
      permission.status;

  /// Shares repeated requests and queues different permissions around the OS prompt.
  static Future<PermissionStatus> request(Permission permission) {
    return _requests.putIfAbsent(permission, () {
      final result = _queue
          .then((_) async {
            final current = await status(permission);
            return current.isDenied ? await permission.request() : current;
          })
          .whenComplete(() {
            _requests.remove(permission);
          });
      _queue = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
      return result;
    });
  }

  static Future<bool> openSettings() => openAppSettings();
}

/// Compatibility helper for callers that require full access.
Future<bool> getPermissionStatus(Permission permission) async =>
    (await PermissionHelper.request(permission)).isGranted;
