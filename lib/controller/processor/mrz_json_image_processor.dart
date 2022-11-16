import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:pm_opencv_plugin/controller/model_extension.dart';
import 'package:pm_opencv_plugin/controller/proc_ffi.dart';

import '../../Exception/exception.dart';
import '../../model/frame_for_process.dart';
import '../../model/image_model.dart';
import '../../model/mrz.dart';
import '../../model/process_result.dart';

Future<IProcessResult<FmMrzOCR>> mrzOcrImgProcessor(FmFrameForProcess frame) async{
  Uint8List? memoryImg;
  IProcessResult<FmMrzOCR> result;

  var imgForProcessP = frame.toFms2nFrameForProcessPointer();//_prepareFrameFroProcessPointer(frame);
  final mrzNativeResult = ffiGetPassImageJson(imgForProcessP);

  imgForProcessP.release();

  //return img is null
  try {
    memoryImg = mrzNativeResult.mapImg2ui8list();
  }on PmException catch(e){
    result = IProcessResult.finished(
        ec: -210,
        pResult: null);
    mrzNativeResult.release();
    return result;
  }on PmExceptionEx catch(e){
    result = IProcessResult.finished(
        ec: -210,
        eMsg: e.msg,
        pResult: null);
    mrzNativeResult.release();
    return result;
  }catch(e){
    result = IProcessResult.finished(
        ec: -210,
        eMsg: e.toString(),
        pResult: null);
    mrzNativeResult.release();
    return result;
  }
  //parse the mrz if
  try {
    String? jsonStr = mrzNativeResult.mapNativeStr2JsonStr();
    Mrz mrz = Mrz.fromJsonString(jsonStr!);
    result = IProcessResult.finished(
        ec:0,
        pResult:FmMrzOCR(memoryImg!, mrz));
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
  return result;
}