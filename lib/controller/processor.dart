
import 'dart:typed_data';

import 'package:pm_opencv_plugin/Exception/exception.dart';
import 'package:pm_opencv_plugin/controller/model_extension.dart';
import 'package:pm_opencv_plugin/controller/proc_ffi.dart';
import 'package:pm_opencv_plugin/mrz_parser-master/lib/mrz_parser.dart';

import 'package:pm_opencv_plugin/model/image_model.dart';
import 'package:pm_opencv_plugin/model/process_result.dart';
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

Future<IProcessResult<FmMrzOCR>> mrzOcrProcessor(FmFrameForProcess frame) async{
  Uint8List? memoryImg;
  IProcessResult<FmMrzOCR> result;

  var imgForProcessP = frame.toFms2nFrameForProcessPointer();//_prepareFrameFroProcessPointer(frame);
  final mrzNativeResult = ffiGetPassportOCR(imgForProcessP);

  void release(){
    imgForProcessP.release();
    mrzNativeResult.release();
  }

  //return img is null
  try {
    memoryImg = mrzNativeResult.mapImg2ui8list();
  }on PmException catch(e){
    release();
    throw PmException(e.errCode);
  }on PmExceptionEx catch(e){
    release();
    throw PmExceptionEx(e.errCode, e.exMsg);
  }
  //parse the mrz if
  try {
    MRZResult? mrzResult = mrzNativeResult.parseMrz();
    result = IProcessResult.finished(
        ec:0,
        pResult:FmMrzOCR(memoryImg!, mrzResult));
  }on PmException catch(e){
    result = IProcessResult.finished(
        ec: e.errCode,
        pResult: FmMrzOCR(memoryImg!, null));
  }on PmExceptionEx catch(e){
    result = IProcessResult.finished(
        ec: e.errCode,
        eMsg: e.exMsg,
        pResult: FmMrzOCR(memoryImg!, null));
  }catch(e){
    result = IProcessResult.finished(
        ec: -204,
        eMsg: e.toString(),
        pResult: FmMrzOCR(memoryImg!, null));
  }
  release();
  return result;
}
