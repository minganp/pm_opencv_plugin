import 'dart:async';
import 'dart:io' show Platform;
import 'package:pm_opencv_plugin/bloc_center/controller/state_center.dart';
import 'package:pm_opencv_plugin/controller/img_proc_handler.dart';
import 'package:pm_opencv_plugin/model/image_model.dart';
import 'package:pm_opencv_plugin/model/process_result.dart';
import '../enum/enum_process_state.dart';
import 'package:camera/camera.dart';


abstract class CommonProcess<T> {
  final CameraController? camController;
  final Function onSuccessCallback;
  final Function onFailCallback;
  int scanFreqMilliseconds = 100;
  double timeOutSeconds = 10;
  CameraImage? cameraImage;
  FmProcessArgument? argument;
  ProcessErr processErr = ProcessErr.normal;
  late Timer _timer ;
  late bool isTimeout = false;
  StateCenter stateCenter = StateCenter();
  late T result;
  late StreamSubscription<ProcessState> stateSubscription;

  StreamController<IProcessResult<T>> resultCtl = StreamController<IProcessResult<T>>();
  abstract Handler<T> handler;

  CommonProcess({
    required this.camController,
      required this.onSuccessCallback,
      required this.onFailCallback,
      this.timeOutSeconds = 10,
      this.scanFreqMilliseconds = 100
  }) {
    stateCenter.initState();
    stateCenter.listen();

      resultCtl.stream.listen((event) {
        print("result comming!${event.runtimeType} ");
        print("event result is null?${event.result==null}");
        result = event.result;
        print("result is null?${result==null}");
        event.errCode <0? stateCenter.setNativeState(NativeState.nativeFailed)
            : stateCenter.setNativeState(NativeState.nativeSucceed);
      });
    stateSubscription = stateCenter.processTState.stream.listen((event) async{
      print("-----processTState: $event");
      await specialProcess(event);
    });
  }

  bool isTimeOut(int ticker) =>
      timeOutSeconds * 1000 / (ticker * scanFreqMilliseconds) < 1.0;

  //entrance for process
  Future<void> startProcessListener(FmProcessArgument? argument) async {
    //_launchListeners();
    //print(stateCenter.isPaused);
    this.argument = argument;
    await _startTimer();
    await _startStreaming();
    //specialProcess();
  }
  Future<void> restartProcess(FmProcessArgument? argument) async {
    _pauseListeners();
    //stateSubscription.pause();
    _stopStream();
    _resetTimer();
    stopNativeProcess();
    stateCenter.initState();
    stateSubscription.resume();
    startProcessListener(argument);
  }
  Future<void> stopProcess() async{
    print("----to stop process");
    _cancelListeners();
    _stopStream();
    _resetTimer();
  }

  // state center, transfer state of streaming,timeout,native process,result state
  // to processState
  //abstract function, should be override
  Future<void> specialProcess(ProcessState state);
  Future<void> startNativeProcess();

  void _launchListeners() {
  }

  void _pauseListeners(){
    stateCenter.pause();
    stateSubscription.pause();
  }
  void _cancelListeners(){
    stateCenter.cancel();
    stateSubscription.cancel();
  }

  Future<void> _startStreaming() async {
    print("Streaming state: streamState:${stateCenter.getStreamState}");
    if (stateCenter.getStreamState != StreamState.idle) return;

    if (Platform.isAndroid || Platform.isIOS) {
      if (camController == null) {
        processErr = ProcessErr.cameraNullException;
        throw Exception(processErr);
      }
      try {
        stateCenter.setStreamState(StreamState.streaming);
        print("will start streaming: streamState:${stateCenter.getStreamState}");

        await camController!.startImageStream((image) async{
          cameraImage = image;
          if(stateCenter.getStreamState != StreamState.frameStreamed){
            stateCenter.setStreamState(StreamState.frameStreamed);
            print("frame streamed: streamState:${stateCenter.getStreamState}");
          }
        });
      } catch (e) {
        processErr = ProcessErr.cameraNullException;
        throw Exception(processErr);
      }
    }
  }
  Future<void> _stopStream() async{
    if(camController == null){
      throw Exception(ProcessErr.cameraNullException);
    }
    if(stateCenter.getStreamState != StreamState.idle){
      await camController!.stopImageStream().then((value){
        stateCenter.setStreamState(StreamState.idle);
      });
    }
  }

  Future<void> _startTimer() async{
    if(stateCenter.getTimerState != TimerState.idle) return;
    stateCenter.setTimerState(TimerState.timerStart);
    _timer=Timer.periodic(const Duration(milliseconds: 100), (timer) {
      print("${timer.tick}");
      if (isTimeOut(timer.tick)) {
        print("----time out");
        stateCenter.setTimerState(TimerState.timeout);
        timer.cancel();
      }
    });
  }
  Future<void> _resetTimer() async{
    _timer.cancel();
    if(stateCenter.getTimerState == TimerState.idle) return;
    stateCenter.setTimerState(TimerState.idle);
  }

  Future<void> stopNativeProcess() async{
    return;
  }
}
