import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:pm_opencv_plugin/bloc/controller/state_center.dart';
import 'package:pm_opencv_plugin/controller/img_proc_handler.dart';
import 'package:pm_opencv_plugin/model/process_result.dart';
import 'package:pm_opencv_plugin/model/process_argument.dart';
import 'package:pm_opencv_plugin/bloc/enum/enum_process_state.dart';
import 'package:camera/camera.dart';

abstract class CommonProcess {
  final CameraController? camController;
  final Function onSuccessCallback;
  final Function onFailCallback;
  int scanFreqMilliseconds = 100;
  double timeOutSeconds = 10;
  CameraImage? cameraImage;
  FmProcessArgument? argument;
  ProcessErr processErr = ProcessErr.normal;
  Timer? _timer;
  StateCenter stateCenter = StateCenter();
  late IProcessResult result;
  late StreamSubscription<ProcessState> stateSubscription;
  late ValueChanged<ProcessState>? stateListener;

  StreamController<IProcessResult> resultCtl;
  Handler handler;

  // state center, transfer state of streaming,timeout,native process,result state
  // to processState
  //abstract function, should be override
  void nextAction(ProcessState state);
  Future<void> startNativeProcess();
  bool isTimeOut(int ticker) =>
      timeOutSeconds * 1000 / (ticker * scanFreqMilliseconds) < 1.0;

  void listen( ValueChanged<ProcessState> listener){
    stateListener = listener;
  }

  CommonProcess({
    required this.camController,
      required this.onSuccessCallback,
      required this.onFailCallback,
      required this.handler,
      required this.resultCtl,
      this.timeOutSeconds = 10,
      this.scanFreqMilliseconds = 100
  }) {
    stateCenter.initState();
    stateCenter.listen();
      resultCtl.stream.listen((event) {
        result = event;
        if (kDebugMode) {
          print("err,Code: ${event.errCode}, Msg: ${event.msg}");
        }
        event.errCode <0? stateCenter.setNativeState(NativeState.nativeFailed)
            : stateCenter.setNativeState(NativeState.nativeSucceed);
      });
    stateSubscription = stateCenter.processTState.stream.listen((event) async{
      if (kDebugMode) {
        print("-----processTState: $event");
      }
      if(stateListener != null)stateListener!(event);
      nextAction(event);
    });
  }

  //entrance for process
  Future<void> startProcess(FmProcessArgument? argument) async {
    //_launchListeners();
    //print(stateCenter.isPaused);
    this.argument = argument;
    await _startTimer();
    await _startStream();
  }
  //not timeout rescan and then begin native start;
  Future<void> inTimeRestart(FmProcessArgument? argument) async {
    await _stopNativeProcess();
    this.argument = argument;
    await _startStream();
  }
  Future<void> stopProcess() async{
    if (kDebugMode) {
      print("----to stop process");
    }
    //_cancelListeners();
    await _stopStream();
    await _stopTimer();
  }
  Future<void> terminateProcess() async{
    await stopProcess();
    _cancelListeners();
  }

  Future<void> resetProcess() async{
    await _stopNativeProcess();
    await _stopTimer();
    await _stopStream();
  }

  void _cancelListeners(){
    stateCenter.cancel();
    stateSubscription.cancel();
  }

  Future<void> _startStream() async {
    if (camController!.value.isStreamingImages) {
      if (stateCenter.getStreamState != StreamState.streaming) {
          stateCenter.setStreamState(StreamState.streaming);
      }
      return;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      if (camController == null) {
        processErr = ProcessErr.cameraNullException;
        throw Exception(processErr);
      }
      try {
        stateCenter.setStreamState(StreamState.streaming);
        await camController!.startImageStream((image) async{
          cameraImage = image;
          if(stateCenter.getStreamState != StreamState.frameStreamed){
            stateCenter.setStreamState(StreamState.frameStreamed);
          }
        });
      } catch (e) {
        processErr = ProcessErr.cameraNullException;
        throw Exception(processErr);
      }
    }else{
      processErr = ProcessErr.platformNotSupportException;
      throw Exception(processErr);
    }
  }
  Future<void> _stopStream() async{
    if(camController == null){
      throw Exception(ProcessErr.cameraNullException);
    }
    if(camController!.value.isStreamingImages){
      await camController!.stopImageStream().then((value){
        stateCenter.setStreamState(StreamState.idle);
      });
    }else if(stateCenter.getStreamState != StreamState.idle){
      stateCenter.setStreamState(StreamState.idle);
    }
  }

  Future<void> _startTimer() async{
    if(stateCenter.getTimerState != TimerState.idle) return;
    stateCenter.setTimerState(TimerState.timerStart);
    _timer=Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (kDebugMode) {
        print("${timer.tick}");
      }
      if (isTimeOut(timer.tick)) {
        if (kDebugMode) {
          print("----time out");
        }
        stateCenter.setTimerState(TimerState.timeout);
        timer.cancel();
      }
    });
  }
  Future<void> _stopTimer() async{
    if(_timer == null) return;
    if(_timer!.isActive) _timer!.cancel();
    if(stateCenter.getTimerState != TimerState.idle) {
      stateCenter.setTimerState(TimerState.idle);
    }
  }

  Future<void> _stopNativeProcess() async{
    int timeoutSeconds = 10;
    double durMilliSeconds = 0;
    while(stateCenter.getNativeState == NativeState.processing){
      Future.delayed(const Duration(milliseconds: 100)).then((_){
        durMilliSeconds = durMilliSeconds + 0.1;
      });
      if(durMilliSeconds>timeoutSeconds){
        throw Exception(ProcessErr.nativeProcessTimeOut);
      }
    }
    stateCenter.setNativeState(NativeState.waiting);
    return;
  }
}
