import 'package:shared_preferences/shared_preferences.dart';

import '../api/flukki_api.dart';

class UserController {
  static final UserController instance = UserController._();

  UserController._();

  static const deviceIdKey = 'flukkiUniqueDeviceId';
  String? _deviceId;
  String? _userId;
  bool _isSignedIn = false;

  String? get userID => _userId ?? _deviceId;

  bool get isSignedIn => _isSignedIn;

  Future<void> init(String apiKey) async {
    await _loadDeviceIdFromPreferences();
  }

  Future<void> signIn(String apiKey, {String? userId}) async {
    if (userId == null) {
      if (_deviceId == null) {
        final newId = await FlukkiApi.createDeviceId(apiKey: apiKey);
        if (newId != null) {
          await _saveDeviceIdToPreferences(newId);
        }
      }
    } else {
      _userId = userId;
    }
    await FlukkiApi.updateDeviceId(userID: userID!, apiKey: apiKey);
    _isSignedIn = true;
  }

  signOut() {
    _isSignedIn = false;
    _userId = null;
  }

  Future<String?> _loadDeviceIdFromPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _deviceId = preferences.getString(deviceIdKey);
      return _deviceId;
    } catch (_) {}
    return null;
  }

  Future<void> _saveDeviceIdToPreferences(String newDeviceId) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(deviceIdKey, newDeviceId);
      _deviceId = newDeviceId;
    } catch (_) {}
  }
}
