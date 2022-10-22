import 'dart:async';

import 'package:rxdart/rxdart.dart';

class TState<T> {
  late T _state;
  BehaviorSubject<T> streamController = BehaviorSubject<T>();
  TState(T iState){
    _state = iState;
    streamController.sink.add(_state);
  }

  set state(T iState) {
    print("before add state: $_state");

    if (_state == iState) return;
    _state = iState;
    print("will add state: $_state");
    streamController.sink.add(_state);
  }

  T get state => _state;

  bool stateCheck(T cState) => _state == cState;

  Stream<T> get stream => streamController.stream;
  dispose() => streamController.close();
}
