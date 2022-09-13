
import 'package:flutter/material.dart';
import 'pages/scannerPage.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

const title = 'Native OpenCV Example';


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

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
      home: ScannerPage(cameras: cameras),
    );
  }
}

