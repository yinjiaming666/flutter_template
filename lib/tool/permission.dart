import 'package:permission_handler/permission_handler.dart';

Future<bool> getPermissionStatus(Permission permission) async {
  final PermissionStatus status = await permission.status;
  if (status.isGranted) {
    return true;
  }
  final PermissionStatus result = await permission.request();
  return result.isGranted;
}
