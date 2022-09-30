
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pm_opencv_plugin/pm_opencv_plugin.dart';
import 'package:pm_opencv_plugin/pm_opencv_plugin_platform_interface.dart';
import 'pages/scannerPage.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;
const title = 'Native OpenCV Example';

String trainedDataPath = "";


//copy mrz.trainneddata to application temporydirectory for native tessert to use
//each time while lunch the app, it used for check if the file exists,
//if not will copy


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  PrepareMrzResult result=await PmOpencvPlugin.initMrzPlugin();
  print("Result: ${result.errCode},Path:${result.trainedPath},Msg:${result.errMsg}");
  result.errCode>=0?trainedDataPath=result.trainedPath:exit;

  cameras=await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScannerPage(cameras: cameras,trainedDataPath: trainedDataPath),
    );
  }
}

