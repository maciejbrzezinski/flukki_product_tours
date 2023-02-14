import 'package:shared_preferences/shared_preferences.dart';

import '../api/flukki_api.dart';

class DeviceIdController {
  static final DeviceIdController instance = DeviceIdController._();

  DeviceIdController._();

  static const deviceIdKey = 'flukkiUniqueDeviceId';
  String? deviceId;

  Future<void> init(String apiKey) async {
    await _loadIdFromPreferences();
    if (deviceId == null) {
      final newId = await FlukkiApi.createDeviceId(apiKey: apiKey);
      if (newId != null) {
        await _saveIdToPreferences(newId);
      }
    } else {
      await FlukkiApi.updateDeviceId(deviceId: deviceId!, apiKey: apiKey);
    }
  }

  Future<String?> _loadIdFromPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      deviceId = preferences.getString(deviceIdKey);
      return deviceId;
    } catch (_) {}
    return null;
  }

  Future<void> _saveIdToPreferences(String newDeviceId) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(deviceIdKey, newDeviceId);
      deviceId = newDeviceId;
    } catch (_) {}
  }
}
