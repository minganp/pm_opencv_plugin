
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pm_opencv_plugin/controller/camera_img_ext.dart';
import 'package:pm_opencv_plugin/model/mich_image_model.dart';
import 'dart:ffi' as ffi;
import 'image_ffi.dart';

class CommonProcess <NT,RT>{
  StreamController<RT> resultStreamController;

  CommonProcess(this.resultStreamController);
  ffi.Pointer<MichImage> _prepareFramePointer(MichFrameForProcess frame) =>
      frame.image.toMichImagePointer(frame.rotation);

  Future<RT?> specialProcess(MichFrameForProcess frame){
    throw UnimplementedError();
  }
  Future<RT?> isolateProcess(MichFrameForProcess imgForProcess) async{
    if(!imgForProcess.image.isEmpty()){
      return compute(
          specialProcess,imgForProcess
      );
    }
    return null;
  }
  Future<void> process(MichFrameForProcess frame) async {
    try {
      final RT? result = await isolateProcess(frame);
      if (result != null) resultStreamController.add(result);
    } catch (e) {
      print(e);
    }
  }
}

class MrzOcrHandler extends CommonProcess<ffi.Pointer<MrzRoiOCR>,MrzResult> {
  MrzOcrHandler(super.resultStreamController);

  @override
  Future<MrzResult?> specialProcess(MichFrameForProcess frame) async{
    final stopwatch = Stopwatch()..start();
    try {
      var imgForProcessP = _prepareFramePointer(frame);
      final mrzNativeResult = getPassportOCR(imgForProcessP);
      stopwatch.stop();
      MrzResult? mrzResult = mrzNativeResult.mrzIONat2MrzResult();
      mrzResult!.processDur = stopwatch.elapsed;
      imgForProcessP.release();
      mrzNativeResult.release();
      return mrzResult;
    }catch(e){
      print(e);
    }
    return null;
  }
}

class PassRoiHandler extends CommonProcess<ffi.Pointer<MichImageMemory>,Uint8List>{
  PassRoiHandler(super.resultStreamController);

  @override
  Future<Uint8List?> specialProcess(MichFrameForProcess frame) async{
    final stopwatch = Stopwatch()..start();
    try{
      var imgForProcessP = _prepareFramePointer(frame);
      final nativeResult = roiStepByStep(imgForProcessP);
      stopwatch.stop();
      Uint8List rtImg = nativeResult.mapImg2UInt8List();
      imgForProcessP.release();
      nativeResult.release();
      return rtImg;
    }catch(e){
      print(e);
    }
    return null;
  }
}

class SimpleImgTrans extends CommonProcess<ffi.Pointer<MichImageMemory>,Uint8List>{
  SimpleImgTrans(super.resultStreamController);

  @override
  Future<Uint8List?> specialProcess(MichFrameForProcess frame) async{
    final stopwatch = Stopwatch()..start();
    try{
      var imgForProcessP = _prepareFramePointer(frame);
      final nativeResult = processNativeImg(imgForProcessP);
      stopwatch.stop();
      Uint8List rtImg = nativeResult.mapImg2UInt8List();
      imgForProcessP.release();
      nativeResult.release();
      return rtImg;
    }catch(e){
      print(e);
    }
    return null;
  }
}