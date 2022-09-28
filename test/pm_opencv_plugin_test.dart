import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pm_opencv_plugin/pm_opencv_plugin.dart';
import 'package:pm_opencv_plugin/pm_opencv_plugin_platform_interface.dart';
import 'package:pm_opencv_plugin/pm_opencv_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPmOpencvPluginPlatform 
    with MockPlatformInterfaceMixin
    implements PmOpencvPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> imageToUTF8Text(Uint8List imgBytes) {
    // TODO: implement imageToUTF8Text
    throw UnimplementedError();
  }
}

void main() {
  final PmOpencvPluginPlatform initialPlatform = PmOpencvPluginPlatform.instance;

  test('$MethodChannelPmOpencvPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPmOpencvPlugin>());
  });

  test('getPlatformVersion', () async {
    PmOpencvPlugin pmOpencvPlugin = PmOpencvPlugin();
    MockPmOpencvPluginPlatform fakePlatform = MockPmOpencvPluginPlatform();
    PmOpencvPluginPlatform.instance = fakePlatform;
  
    expect(await pmOpencvPlugin.getPlatformVersion(), '42');
  });
}
