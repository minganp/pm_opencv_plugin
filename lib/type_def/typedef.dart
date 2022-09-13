import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

String androidLib='libflutter_opencv_plugin.so';
String winLib='native_opencv_windows_plugin.dll';

class ProcessStatus{
  bool isProcessed=false;
  bool isWorking=false;

  ProcessStatus({isProcessed,isWorking});
}