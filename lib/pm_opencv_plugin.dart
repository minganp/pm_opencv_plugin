
import 'dart:typed_data';
import 'pm_opencv_plugin_platform_interface.dart';

class PmOpencvPlugin{

  Future<String?> getPlatformVersion() {
    return PmOpencvPluginPlatform.instance.getPlatformVersion();
  }

  Future<String?> imageToText(Uint8List image){
    return PmOpencvPluginPlatform.instance.imageToUTF8Text(image);
  }
}
