import 'package:package_info_plus/package_info_plus.dart';

class AppVersionController {
  static final AppVersionController instance = AppVersionController._();

  AppVersionController._();

  static List? _currentVersion;

  Future<void> init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version.split('.');
    _currentVersion!.add(packageInfo.buildNumber);
  }

  /// Returns the current app version in format x.y.z+buildNumber.
  String get currentVersion {
    return '${_currentVersion![0]}.${_currentVersion![1]}.${_currentVersion![2]}+${_currentVersion![3]}';
  }

  /// Checks if the current app version is greater or equal to the given version.
  ///
  /// Format of [version] should be x.y.z+buildNumber.
  /// Example: 1.0.0+1
  bool isCurrentVersionGreaterEqual(String version) {
    final List<String> savedParts = version.split('+');
    List<String> savedVersion = savedParts[0].split('.');
    savedVersion.add(savedParts[1]);

    for (var i = 0; i < 4; i++) {
      final numSaved = int.parse(savedVersion[i]);
      final numCurrent = int.parse(_currentVersion![i]);
      if (numCurrent < numSaved) {
        return false;
      } else if (numCurrent > numSaved) {
        return true;
      }
    }

    return true;
  }
}
