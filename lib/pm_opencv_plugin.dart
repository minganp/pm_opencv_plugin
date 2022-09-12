
import 'pm_opencv_plugin_platform_interface.dart';

class PmOpencvPlugin {
  Future<String?> getPlatformVersion() {
    return PmOpencvPluginPlatform.instance.getPlatformVersion();
  }
}
