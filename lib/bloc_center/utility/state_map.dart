
import 'package:rxdart/rxdart.dart';

import '../controller/state_center.dart';
import '../enum/enum_process_state.dart';
/*
List readyState = [StreamState.idle,TimerState.idle,NativeState.waiting];
List canStartState = [StreamState.frameStreamed,TimerState.timerStart,NativeState.waiting];
List processBusyState = [NativeState.processing];
List timeoutFailedState = [TimerState.timeout, NativeState.nativeFailed];
List noTimeoutFailedState = [TimerState.timerStart,NativeState.nativeFailed];
List timeoutSuccessState = [TimerState.timeout,NativeState.nativeSucceed];
List noTimeoutSuccessState = [TimerState.timerStart,NativeState.nativeSucceed];

Map<ProcessState,List> stateMap = {
  ProcessState.ready : readyState,
  ProcessState.canStart : canStartState,
  ProcessState.processBusy : canStartState,
  ProcessState.noTimeoutFailed : noTimeoutFailedState,
  ProcessState.noTimeoutSuccess : noTimeoutSuccessState,
  ProcessState.timeoutFailed : timeoutFailedState,
  ProcessState.timeoutSuccess : timeoutSuccessState
};
*/
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
  return processState;
}