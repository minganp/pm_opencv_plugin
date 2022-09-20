import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pm_opencv_plugin_platform_interface.dart';

/// An implementation of [PmOpencvPluginPlatform] that uses method channels.
class MethodChannelPmOpencvPlugin extends PmOpencvPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  var methodChannel = const MethodChannel('pm_opencv_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final String? version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> imageToUTF8Text(Uint8List imgBytes) async {
    String text = await methodChannel.invokeMethod('imageToUTF8Text', {"imageBytes":imgBytes});
    return text;
  }
}
