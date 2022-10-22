enum ProcessState {
  ready,  //waiting for prepared
  canStart,   //can start process
  processBusy, //native process is busy
  timeoutFailed,  //
  noTimeoutFailed,
  timeoutSuccess,
  noTimeoutSuccess,
}

enum StreamState {
  idle,
  streaming,
  frameStreamed,
}

enum TimerState {
  idle,
  timerStart,
  timeout,
}

enum NativeState{
  waiting,
  processing,
  nativeSucceed,
  nativeFailed,
}
/*
enum ResultState {
  none,
  failed,
  succeed,
}
*/
enum ProcessErr {
  normal,
  cameraNullException,
  cameraImageNullException,
  cameraStreamException,
}