import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pm_opencv_plugin_method_channel.dart';

abstract class PmOpencvPluginPlatform extends PlatformInterface {
  /// Constructs a PmOpencvPluginPlatform.
  PmOpencvPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static PmOpencvPluginPlatform _instance = MethodChannelPmOpencvPlugin();

  /// The default instance of [PmOpencvPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelPmOpencvPlugin].
  static PmOpencvPluginPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PmOpencvPluginPlatform] when
  /// they register themselves.
  static set instance(PmOpencvPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> imageToUTF8Text(Uint8List imgBytes){
    throw UnimplementedError('imageToText() has not been implemented');
  }
}
