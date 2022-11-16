
import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:pm_opencv_plugin/Exception/exception.dart';
import 'package:pm_opencv_plugin/controller/model_extension.dart';
import 'package:pm_opencv_plugin/controller/proc_ffi.dart';

import 'package:pm_opencv_plugin/model/image_model.dart';
import 'package:pm_opencv_plugin/model/process_result.dart';

import '../model/frame_for_process.dart';
import '../model/mrz.dart';
Future<IProcessResult<FmMrzOCR2>> mrzRoiProcess(FmFrameForProcess frame) async {
    final stopwatch = Stopwatch()..start();
//    try {
      print("----frame info: ${frame.processArgument?.pMrzTFD}");
      var imgForProcessP = frame.toFms2nFrameForProcessPointer();//_prepareFrameFroProcessPointer(frame);
      final mrzNativeResult = ffiGetMrzRoi(imgForProcessP);
      stopwatch.stop();
      final mrzResult = await mrzNativeResult.toMrzResult();
      mrzResult.processDur = stopwatch.elapsed;
      imgForProcessP.release();
      mrzNativeResult.release();
      return IProcessResult.finished(
          ec:0,
          pResult: mrzResult);
/*
    }catch(e){
      print(e.toString());
      //return IProcessResult.finished(ec: -1, pResult: );
    }
 */
}


Future<IProcessResult<FmMrzJson>> mrzJsonProcessor(FmFrameForProcess frame) async{
  IProcessResult<FmMrzJson> result;
  var imgForProcessP = frame.toFms2nFrameForProcessPointer();//_prepareFrameFroProcessPointer(frame);
  ffi.Pointer<Utf8> mrzNativeResult = ffiGetMrzJson(imgForProcessP);
  String r = mrzNativeResult.toDartString();
    try {
      Mrz mrz = Mrz.fromJsonString(r);
      result = IProcessResult.finished(
          ec: 0,
          pResult: FmMrzJson(mrz));
    }on PmExceptionEx catch(e){
      result = IProcessResult.finished(
          ec: -206,
          eMsg: e.msg,
          pResult: FmMrzJson(null));
    }catch(e){
      print(e.toString());
      result = IProcessResult.finished(
          ec: -206,
          eMsg: e.toString(),
          pResult: FmMrzJson(null));
    }
    imgForProcessP.release();
    //malloc.free(mrzNativeResult);
    return result;
}
