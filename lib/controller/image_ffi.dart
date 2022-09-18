import 'dart:ffi' as ffi;

import 'dart:io';

import 'package:pm_opencv_plugin/model/mich_image_model.dart';

typedef CCreateMichImg = ffi.Pointer<MichImage> Function();
typedef CreateMichImg = ffi.Pointer<MichImage> Function();

typedef CCreateMichImgPlane = ffi.Pointer<MichImagePlane> Function();
typedef CreateMichImgPlane = ffi.Pointer<MichImagePlane> Function();

//image struct returned by opencv for flutter Image.memory to use
typedef CCreateRtImg = ffi.Pointer<MichImageMemory> Function();
typedef CreateRtImg = ffi.Pointer<MichImageMemory> Function();

typedef CProcessImg = ffi.Pointer<MichImageMemory> Function(ffi.Pointer<MichImage>);
typedef ProcessImg = ffi.Pointer<MichImageMemory> Function(ffi.Pointer<MichImage>);

typedef CProcessImg2 = ffi.Void Function(ffi.Pointer<MichImage>,ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Uint32>);
typedef ProcessImg2 = void Function(ffi.Pointer<MichImage>,ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Uint32>);

ffi.DynamicLibrary _openDynamicLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libOpenCV_ffi.so');
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open("main.dll");
  }

  return ffi.DynamicLibrary.process();
}
ffi.DynamicLibrary _lib = _openDynamicLibrary();

final ProcessImg processNativeImg = _lib
    .lookup<ffi.NativeFunction<CProcessImg>>("processAndroidImage")
    .asFunction();

final ProcessImg roiStepByStep = _lib
    .lookup<ffi.NativeFunction<CProcessImg>>("getRoiMrzStepByStep")
    .asFunction();

final ProcessImg2 processNativeImg2 = _lib
    .lookup<ffi.NativeFunction<CProcessImg2>>("processAndroidImage2")
    .asFunction();

final CreateMichImg createImg =  _lib
    .lookup<ffi.NativeFunction<CCreateMichImg>>("createImage")
    .asFunction();

final CreateMichImgPlane createImgPlane = _lib
    .lookup<ffi.NativeFunction<CCreateMichImgPlane>>("createImagePlane")
    .asFunction();

final CreateRtImg createRtImg = _lib
    .lookup<ffi.NativeFunction<CCreateRtImg>>("createRtImgFmt")
    .asFunction();



