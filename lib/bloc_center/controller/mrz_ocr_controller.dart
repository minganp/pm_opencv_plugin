import 'dart:async';

import 'package:pm_opencv_plugin/controller/img_proc_handler.dart';
import 'package:pm_opencv_plugin/model/image_model.dart';
import 'package:pm_opencv_plugin/bloc_center/enum/enum_process_state.dart';
import 'package:pm_opencv_plugin/bloc_center/controller/i_process_controller.dart';
class MrzProcessController extends CommonProcess<FmMrzOCR>{


  @override
  late Handler<FmMrzOCR> handler;

  MrzProcessController({
    super.scanFreqMilliseconds,
    super.timeOutSeconds,
    super.camController,
    required super.onSuccessCallback,
    required super.onFailCallback,
  }):super(){
    handler = MrzOcrHandler(resultStreamController: resultCtl);
  }

  @override
  Future<void> specialProcess(ProcessState state) async{
    print("----specialProcess, processState:$state");
    if(state == ProcessState.canStart){
        await startNativeProcess();
      }else if(state == ProcessState.noTimeoutFailed){
        restartProcess(argument);
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
      print("----mrz_ocr_controller:cameraImage null");
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
    print("----mrz_ocr_controller:will process");
    await handler.process(frameForProcess);
  }
}

