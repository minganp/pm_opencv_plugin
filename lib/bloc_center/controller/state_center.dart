import 'dart:async';

import 'package:pm_opencv_plugin/bloc_center/controller/t_state.dart';
import 'package:rxdart/rxdart.dart';

import '../enum/enum_process_state.dart';
class ProStates{
  final StreamState? streamState;
  final NativeState? nativeState;
  final TimerState? timeoutState;
  ProStates(this.streamState,this.nativeState,this.timeoutState);
}
class StateCenter{
  late TState<ProcessState> processTState ;
  late TState<StreamState> streamTState;
  late TState<TimerState> timerTState;
  late TState<NativeState> nativeTState;
  late Stream<ProStates> combineStream;
  late StreamSubscription<ProStates> combineSubscription;
  late StreamSubscription<StreamState> streamSubscription;
  late StreamSubscription<TimerState> timerSubscription;
  late StreamSubscription<NativeState> nativeSubscription;


  StateCenter(){
    initState();
    combineStream = Rx.combineLatest3<StreamState,NativeState,TimerState,ProStates>(
        streamTState.streamController.stream,
        nativeTState.streamController.stream,
        timerTState.streamController.stream,
            (stream,native,timeout) => ProStates(stream, native, timeout)
    );
  }
  void initState(){
    processTState = TState(ProcessState.ready);
    streamTState = TState(StreamState.idle);
    timerTState = TState(TimerState.idle);
    nativeTState = TState(NativeState.waiting);
  }
  void listen(){
    print("begin listen");
    streamSubscription = streamTState.stream.listen((event) {
      combine();
    });
    timerSubscription = timerTState.stream.listen((event){
      combine();
    });
    nativeSubscription = nativeTState.stream.listen((event) {
      combine();
    });
    /*
    combineSubscription = combineStream.listen((event) {
      print("--stream Coming!");
      var p = mapProcState(event);
      if(p != null) processTState.state = p;
    });
    */
  }
  void combine(){
    print("---Comtine State");
    var p = mapProcState(
        ProStates(
            streamTState.state, nativeTState.state, timerTState.state));
    if(p != null) processTState.state = p;
  }


  void setStreamState(StreamState state) => streamTState.state = state;
  void setTimerState(TimerState state) => timerTState.state = state;
  void setNativeState(NativeState state) => nativeTState.state = state;
  void setProcessState(ProcessState state) => processTState.state = state;

  StreamState get getStreamState => streamTState.state;
  TimerState get getTimerState => timerTState.state;
  NativeState get getNativeState => nativeTState.state;
  ProcessState get getProcessState => processTState.state;

  void pause() {
    nativeSubscription.pause();
    timerSubscription.pause();
    streamSubscription.pause();
    //combineSubscription.pause();
  }
  void cancel() {
    nativeSubscription.cancel();
    timerSubscription.cancel();
    streamSubscription.cancel();

    //combineSubscription.cancel();
  }
    bool get isPaused => combineSubscription.isPaused;

    void dispose(){
      processTState.dispose();
      streamTState.dispose();
      timerTState.dispose();
      nativeTState.dispose();
    }
}

ProcessState? mapProcState(ProStates state){
  ProcessState? processState;

  if(state.streamState == StreamState.idle
      && state.timeoutState == TimerState.idle
      && state.nativeState == NativeState.waiting){
    processState = ProcessState.ready;
  }else if(state.streamState == StreamState.frameStreamed
      && state.timeoutState == TimerState.timerStart
      && state.nativeState == NativeState.waiting
  ){
    processState = ProcessState.canStart;
  }else if(state.nativeState == NativeState.processing){
    processState = ProcessState.processBusy;
  }else if(state.timeoutState == TimerState.timeout
      && state.nativeState == NativeState.nativeFailed
  ){
    processState = ProcessState.timeoutFailed;
  }else if(state.timeoutState == TimerState.timerStart
      && state.nativeState == NativeState.nativeFailed
  ){
    processState = ProcessState.noTimeoutFailed;
  }
  else if(state.timeoutState == TimerState.timeout
      && state.nativeState == NativeState.nativeSucceed
  ){
    processState = ProcessState.timeoutSuccess;
  }else if(state.timeoutState == TimerState.timerStart
      && state.nativeState == NativeState.nativeSucceed
  ){
    processState = ProcessState.noTimeoutSuccess;
  }
  /*
  print("ProStates:${state.nativeState}");
  print("ProStates:${state.timeoutState}");
  print("ProStates:${state.streamState}");
   */
  print("processState: ${processState??'none'}");
  return processState;
}