
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pm_opencv_plugin/controller/model_extension.dart';
import 'package:pm_opencv_plugin/model/image_model.dart';
import 'dart:ffi' as ffi;
import 'proc_ffi.dart';
import 'package:path_provider/path_provider.dart';


abstract class CommonProcess <NT,RT>{   //nt for native return type, rt for flutter return type
  StreamController<RT> resultStreamController;
  CommonProcess({required this.resultStreamController});

  ffi.Pointer<Fms2nFrameForProcess> _prepareFrameFroProcessPointer(
      FmFrameForProcess frame) =>
      frame.toFms2nFrameForProcessPointer();

  Future<RT?> specialProcess(FmFrameForProcess frame){
    throw UnimplementedError();
  }
  Future<RT?> isolateProcess(FmFrameForProcess imgForProcess) async{
    if(!imgForProcess.image.isEmpty()){
      print("----here argument::${imgForProcess.processArgument?.pMrzTFD}");
      return compute(
          specialProcess,imgForProcess
      );
    }
    return null;
  }

  Future<void> process(FmFrameForProcess frame) async {
    print("----from process: ${frame.rotation}");
    print("----from process: ${frame.image.height}");

    try {
      final RT? result = await isolateProcess(frame);
      if (result != null) resultStreamController.add(result);
    } catch (e) {
      print(e);
    }
  }
}

class MrzOcrHandler {
  FmProcessArgument? processArgument;
  StreamController<FmMrzOCR> resultStreamController;

  static Future<FmMrzOCR?> specialProcess(FmFrameForProcess frame) async{
    print("----enter special process");
    final stopwatch = Stopwatch()..start();
    try {
      print("----frame info: ${frame.processArgument?.pMrzTFD}");
      var imgForProcessP = frame.toFms2nFrameForProcessPointer();//_prepareFrameFroProcessPointer(frame);
      final mrzNativeResult = ffiGetPassportOCR(imgForProcessP);
      stopwatch.stop();
      FmMrzOCR? mrzResult = mrzNativeResult.mrzIONat2MrzResult();
      mrzResult!.processDur = stopwatch.elapsed;
      imgForProcessP.release();
      mrzNativeResult.release();
      return mrzResult;
    }catch(e){
      print(e);
    }
    return null;
  }

  ffi.Pointer<Fms2nFrameForProcess> _prepareFrameFroProcessPointer(
      FmFrameForProcess frame) =>
      frame.toFms2nFrameForProcessPointer();
  MrzOcrHandler({
      required this.resultStreamController,
        this.processArgument});
  Future<void> process(FmFrameForProcess frame) async{
    print("----from process: ${frame.rotation}");
    print("----from process: ${frame.image.height}");
    final trainedDataDir = (await getApplicationDocumentsDirectory()).path;
    const trainedFile = "mrz.traineddata";
    if(processArgument==null) {
      frame.processArgument = FmProcessArgument();
      frame.processArgument!.pMrzTFD = trainedDataDir;
      frame.processArgument!.pMrzTF = trainedFile;
    }else {
      frame.processArgument = processArgument;
    }
    try {
      final FmMrzOCR? result = await isolateProcess(frame);
      if (result != null) {
        print("----Wonderful result:${result.ocrText}");
        resultStreamController.add(result);
      }
    } catch (e) {
      print(e);
    }
  }
  Future<FmMrzOCR?> isolateProcess(FmFrameForProcess imgForProcess) async{
    if(!imgForProcess.image.isEmpty()){
      print("----here argument::${imgForProcess.processArgument?.pMrzTFD}");
      print("----here argument::${imgForProcess.processArgument?.pMrzTF}");
      //imgForProcess.toFms2nFrameForProcessPointer();
      return compute(
          specialProcess,imgForProcess
      );
    }
    return null;
  }
}

class PassRoiHandler extends CommonProcess<ffi.Pointer<FmsfnImage>,Uint8List>{
  PassRoiHandler({required super.resultStreamController});

  @override
  Future<Uint8List?> specialProcess(FmFrameForProcess frame) async{
    final stopwatch = Stopwatch()..start();
    try{
      var imgForProcessP = _prepareFrameFroProcessPointer(frame);
      final nativeResult = ffiRoiStepByStep(imgForProcessP);
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

class SimpleImgTrans extends CommonProcess<ffi.Pointer<FmsfnImage>,Uint8List>{
  SimpleImgTrans({required super.resultStreamController});

  @override
  Future<Uint8List?> specialProcess(FmFrameForProcess frame) async{
    final stopwatch = Stopwatch()..start();
    try{
      var imgForProcessP = _prepareFrameFroProcessPointer(frame);
      final nativeResult = ffiProcessImg(imgForProcessP);
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