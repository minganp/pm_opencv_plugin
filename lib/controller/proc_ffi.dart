import 'dart:ffi' as ffi;

import 'dart:io';

import 'package:pm_opencv_plugin/model/image_model.dart';

//to obtain image pointer from native
typedef CCreateMichImg = ffi.Pointer<Fms2nImage> Function();
typedef CreateMichImg = ffi.Pointer<Fms2nImage> Function();

//to obtain image plane pointer from native
typedef CCreateMichImgPlane = ffi.Pointer<Fms2nImagePlane> Function();
typedef CreateMichImgPlane = ffi.Pointer<Fms2nImagePlane> Function();

//to obtain image pointer which will contain image(FmsfnImage)
typedef CCreateRtImg = ffi.Pointer<FmsfnImage> Function();
typedef CreateRtImg = ffi.Pointer<FmsfnImage> Function();

//to obtain image pointer which will contain frame for process
typedef CCreateFrameForProcess = ffi.Pointer<Fms2nFrameForProcess> Function();
typedef FCreateFrameForProcess = ffi.Pointer<Fms2nFrameForProcess> Function();

//image struct returned by opencv for flutter Image.memory to use
typedef CProcessImg = ffi.Pointer<FmsfnImage> Function(ffi.Pointer<Fms2nFrameForProcess>);
typedef ProcessImg = ffi.Pointer<FmsfnImage> Function(ffi.Pointer<Fms2nFrameForProcess>);

typedef CProcessImg2 = ffi.Void Function(ffi.Pointer<Fms2nImage>,ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Uint32>);
typedef ProcessImg2 = void Function(ffi.Pointer<Fms2nImage>,ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Uint32>);


//input the passport image,get the ocr text back
typedef CMrzRoiOCR = ffi.Pointer<FmsfnMrzOCR> Function(ffi.Pointer<Fms2nFrameForProcess>);
typedef MrzRoiOcr = ffi.Pointer<FmsfnMrzOCR> Function(ffi.Pointer<Fms2nFrameForProcess>);
//to obtain pointer from native
typedef CCreateImageProcessArgument = ffi.Pointer<Fms2nProcessArgument> Function();
typedef FCreateImageProcessArgument = ffi.Pointer<Fms2nProcessArgument> Function();
ffi.DynamicLibrary _openDynamicLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libOpenCV_ffi.so');
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open("main.dll");
  }

  return ffi.DynamicLibrary.process();
}
ffi.DynamicLibrary _lib = _openDynamicLibrary();

final CreateMichImg ffiCreateImgP =  _lib
    .lookup<ffi.NativeFunction<CCreateMichImg>>("createImage")
    .asFunction();
final FCreateImageProcessArgument ffiCreateArgumentP = _lib
    .lookup<ffi.NativeFunction<CCreateImageProcessArgument>>("createProcessArgumentP")
    .asFunction();
final CreateMichImgPlane ffiCreateImgPlaneP = _lib
    .lookup<ffi.NativeFunction<CCreateMichImgPlane>>("createImagePlane")
    .asFunction();
final FCreateFrameForProcess ffiCreateFrameForProcessP = _lib
    .lookup<ffi.NativeFunction<CCreateFrameForProcess>>("createImagePorProcess")
    .asFunction();


final CreateRtImg ffiCreateRtImg = _lib
    .lookup<ffi.NativeFunction<CCreateRtImg>>("createRtImgFmt")
    .asFunction();

final MrzRoiOcr ffiGetPassportOCR = _lib
    .lookup<ffi.NativeFunction<CMrzRoiOCR>>("getImgMrz")
    .asFunction();
final ProcessImg ffiRoiStepByStep = _lib
    .lookup<ffi.NativeFunction<CProcessImg>>("getRoiMrzStepByStep")
    .asFunction();
final ProcessImg2 ffiProcessImg2 = _lib
    .lookup<ffi.NativeFunction<CProcessImg2>>("processAndroidImage2")
    .asFunction();
final ProcessImg ffiProcessImg = _lib
    .lookup<ffi.NativeFunction<CProcessImg>>("processAndroidImage")
    .asFunction();
