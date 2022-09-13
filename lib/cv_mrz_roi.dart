import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart';
// C function signatures
typedef _CVersionFunc = ffi.Pointer<Utf8> Function();
typedef _CProcessImageFunc = ffi.Void Function(
    ffi.Pointer<Utf8>,
    ffi.Pointer<Utf8>,
    );
typedef _CProcessUImageFunc = ffi.Pointer<ffi.Uint8> Function(
    ffi.Int32 width,
    ffi.Int32 height,
    ffi.Pointer<ffi.Uint8> bytes);
// Dart function signatures
typedef _VersionFunc = ffi.Pointer<Utf8> Function();
typedef _ProcessImageFunc = void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>);
typedef _ProcessUImageFunc = ffi.Pointer<ffi.Uint8> Function(int width,int height,ffi.Pointer<ffi.Uint8> bytes);
// Getting a library that holds needed symbols
ffi.DynamicLibrary _openDynamicLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libflutter_opencv_plugin.so');
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open("native_opencv_windows_plugin.dll");
  }

  return ffi.DynamicLibrary.process();
}

ffi.DynamicLibrary _lib = _openDynamicLibrary();

// Looking for the functions
final _VersionFunc _version =
_lib.lookup<ffi.NativeFunction<_CVersionFunc>>('version').asFunction();
final _ProcessImageFunc _processImage = _lib
    .lookup<ffi.NativeFunction<_CProcessImageFunc>>('process_image')
    .asFunction();
final _ProcessUImageFunc _processUImageFunc = _lib
    .lookup<ffi.NativeFunction<_CProcessUImageFunc>>('symbolName')
    .asFunction();
String opencvVersion() {
  return _version().toDartString();
}

void processImage(ProcessImageArguments args) {
  _processImage(args.inputPath.toNativeUtf8(), args.outputPath.toNativeUtf8());
}

class ProcessImageArguments {
  final String inputPath;
  final String outputPath;

  ProcessImageArguments(this.inputPath, this.outputPath);
}