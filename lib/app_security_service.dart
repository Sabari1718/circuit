import 'package:package_info_plus/package_info_plus.dart';

class AppSecurityService {

  static Future<bool> checkApp() async {

    final info = await PackageInfo.fromPlatform();

    const allowedAppId =
        "com.example.circuit";

    const allowedAppName =
        "circuit";

    const allowedVersion =
        "1.0.0";

    bool valid =
        info.packageName == allowedAppId &&
            info.appName == allowedAppName &&
            info.version == allowedVersion;

    return valid;
  }
}
