import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../type_def/typedef.dart';

// C function signatures
typedef _CVersionFunc = ffi.Pointer<Utf8> Function();
typedef _CProcessImageFunc = ffi.Void Function(
    ffi.Pointer<Utf8>,
    ffi.Pointer<Utf8>,
    );
typedef _VersionFunc = ffi.Pointer<Utf8> Function();
typedef _ProcessImageFunc = void Function(ffi.Pointer<Utf8>,ffi.Pointer<Utf8>);

class Cv {
  final port = ReceivePort();
  BehaviorSubject<ProcessStatus> processStatusController = BehaviorSubject<
      ProcessStatus>();

  Stream<ProcessStatus> get pStatusStream => processStatusController.stream;

  Function(ProcessStatus) get pStatusAdd => processStatusController.sink.add;
  ffi.DynamicLibrary? _lib;
  _VersionFunc? _version;
  _ProcessImageFunc? _processImage;

  Cv() {
    _lib = _openDynamicLibrary();
    _version =
        _lib?.lookup<ffi.NativeFunction<_CVersionFunc>>('version').asFunction();
    _processImage =
        _lib?.lookup<ffi.NativeFunction<_CProcessImageFunc>>('process_image')
            .asFunction();
    if (kDebugMode) {
      print(
          _processImage == null ? "-----processImage null" : "------not null");
    }
  }


  ffi.DynamicLibrary _openDynamicLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open(androidLib);
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open(winLib);
    }
    return ffi.DynamicLibrary.process();
  }

  String opencvVersion() => _version!().toDartString();

  void processImage(ProcessImageArguments args) {
   if (kDebugMode) {
     print("-----OutputPath:${args.outputPath}");
   }
    _processImage!(
        args.inputPath.toNativeUtf8(), args.outputPath.toNativeUtf8());
    if (kDebugMode) {
      print("-----Image Processed");
    }
  }

}
class ProcessImageArguments{
  final String inputPath;
  final String outputPath;

  ProcessImageArguments(this.inputPath,this.outputPath);
}