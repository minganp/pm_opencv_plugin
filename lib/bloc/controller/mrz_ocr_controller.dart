import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pm_opencv_plugin/bloc/enum/enum_process_state.dart';
import 'package:pm_opencv_plugin/bloc/controller/i_process_controller.dart';
import 'package:pm_opencv_plugin/model/frame_for_process.dart';

class MrzProcessController extends CommonProcess{

  MrzProcessController({
    super.scanFreqMilliseconds,
    super.timeOutSeconds,
    super.camController,
    required super.handler,
    required super.resultCtl,
    required super.onSuccessCallback,
    required super.onFailCallback,
  }):super(){
    //handler = MrzOcrHandler(resultStreamController: resultCtl);
  }

  @override
  Future<void> nextAction(ProcessState state) async{
    if (kDebugMode) {
      print("----specialProcess, processState:$state");
    }
    if(state == ProcessState.canStart){
        await startNativeProcess();
      }else if(state == ProcessState.noTimeoutFailed){
        inTimeRestart(argument);
      }else if(state == ProcessState.timeoutFailed){
        stopProcess();
        onFailCallback(result);
      }else if(state == ProcessState.timeoutSuccess){
        stopProcess();
        onSuccessCallback(result);
      }else if(state == ProcessState.noTimeoutSuccess){
        stopProcess();
        onSuccessCallback(result);
      }else if(state == ProcessState.canStart){
        await startNativeProcess();
      }
  }

  @override
  Future<void> startNativeProcess() async{
    if(stateCenter.nativeTState.state == NativeState.processing)return;
    stateCenter.nativeTState.state = NativeState.processing;

    int rotation = 0;
    if(cameraImage == null) {
      if (kDebugMode) {
        print("----mrz_ocr_controller:cameraImage null");
      }
      processErr = ProcessErr.cameraImageNullException;
      throw Exception(processErr);
    }
    FmFrameForProcess frameForProcess = FmFrameForProcess(
        image: cameraImage!,
        rotation: 0,
        processArgument:argument);
    frameForProcess.image = cameraImage!;
    frameForProcess.rotation = rotation;
    //FmFrameForProcess(image:_cameraImage, rotation: rotation);
    if (kDebugMode) {
      print("----mrz_ocr_controller:will process");
    }
    await handler.process(frameForProcess);
  }
}


//for this controller, only stream once if process failed.
// better for the retry by native process handler,
//When native failed, will stop whole process.
class MrzNativeTryController extends CommonProcess{

  MrzNativeTryController({
    super.scanFreqMilliseconds,
    super.timeOutSeconds,
    super.camController,
    required super.handler,
    required super.resultCtl,
    required super.onSuccessCallback,
    required super.onFailCallback,
  }):super(){
    //handler = MrzOcrHandler(resultStreamController: resultCtl);
  }

  //process
  @override
  void nextAction(ProcessState state) {
    if (kDebugMode) {
      print("----specialProcess, processState:$state");
    }
    if(state == ProcessState.canStart){
      startNativeProcess();
    }else if(state == ProcessState.noTimeoutFailed){
      stopProcess();
      onFailCallback(result);
    }else if(state == ProcessState.timeoutFailed){
      stopProcess();
      onFailCallback(result);
    }else if(state == ProcessState.timeoutSuccess){
      stopProcess();
      onSuccessCallback(result);
    }else if(state == ProcessState.noTimeoutSuccess){
      stopProcess();
      onSuccessCallback(result);
    }
  }

  @override
  Future<void> startNativeProcess() async{
    if(stateCenter.nativeTState.state == NativeState.processing)return;
    stateCenter.nativeTState.state = NativeState.processing;

    int rotation = 0;
    if(cameraImage == null) {
      if (kDebugMode) {
        print("----mrz_ocr_controller:cameraImage null");
      }
      processErr = ProcessErr.cameraImageNullException;
      throw Exception(processErr);
    }
    FmFrameForProcess frameForProcess = FmFrameForProcess(
        image: cameraImage!,
        rotation: 0,
        processArgument:argument);
    frameForProcess.image = cameraImage!;
    frameForProcess.rotation = rotation;
    //FmFrameForProcess(image:_cameraImage, rotation: rotation);
    if (kDebugMode) {
      print("----mrz_ocr_controller:will process");
    }
    await handler.process(frameForProcess);
  }
}

