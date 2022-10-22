

import 'package:pm_opencv_plugin/controller/model_extension.dart';
import 'package:pm_opencv_plugin/controller/proc_ffi.dart';

import '../model/image_model.dart';
Future<FmMrzOCR2?> mrzRoiProcess(FmFrameForProcess frame) async {
    final stopwatch = Stopwatch()..start();
    try {
      print("----frame info: ${frame.processArgument?.pMrzTFD}");
      var imgForProcessP = frame.toFms2nFrameForProcessPointer();//_prepareFrameFroProcessPointer(frame);
      final mrzNativeResult = ffiGetMrzRoi(imgForProcessP);
      stopwatch.stop();
      final mrzResult = await mrzNativeResult.toMrzResult();
      mrzResult?.processDur = stopwatch.elapsed;
      imgForProcessP.release();
      mrzNativeResult.release();
      return mrzResult;
    }catch(e){
      return null;
    }
}

Future<FmMrzOCR?> mrzOcrProcessor(FmFrameForProcess frame) async{
  final stopwatch = Stopwatch()..start();
  try {
    //print("----frame info: ${frame.processArgument?.pMrzTFD}");
    var imgForProcessP = frame.toFms2nFrameForProcessPointer();//_prepareFrameFroProcessPointer(frame);
    final mrzNativeResult = ffiGetPassportOCR(imgForProcessP);
    stopwatch.stop();
    FmMrzOCR? mrzResult = await mrzNativeResult.mrzROINat2MrzResult();
    mrzResult!.processDur = stopwatch.elapsed;
    imgForProcessP.release();
    mrzNativeResult.release();
    return mrzResult;
  }catch(e){
    return null;
  }
}
