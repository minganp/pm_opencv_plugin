
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pm_opencv_plugin/pm_opencv_plugin_method_channel.dart';

import 'pm_opencv_plugin_platform_interface.dart';

class PmOpencvPlugin{
  static Future<PrepareMrzResult> initMrzPlugin()async{
    //check mrz.trainneddata exists
    /*
    late Directory appDir;
    await getApplicationDocumentsDirectory().then((dir) => appDir = dir);
    const String filename = "mrz.traineddata";
    String destName = '${appDir.path}/$filename';
    final persistFile = File(destName);
    if(await persistFile.exists())return;
    print("----From plugin PmOpencvPlugin: $filename not exist,will copy");

    var bytes = await rootBundle.load('packages/pm_opencv_plugin/assets/ocrTrainedData/$filename');
    await File(destName).writeAsBytes(bytes.buffer.asUint8List());

     */
    return PmOpencvPluginPlatform.instance.initMrzTrainedData();
  }
  Future<String?> getPlatformVersion() {
    return PmOpencvPluginPlatform.instance.getPlatformVersion();
  }

  Future<String?> imageToText(Uint8List image){
    return PmOpencvPluginPlatform.instance.imageToUTF8Text(image);
  }
}
