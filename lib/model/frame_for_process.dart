import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:pm_opencv_plugin/controller/model_extension.dart';
import 'dart:ffi' as ffi;

import 'package:pm_opencv_plugin/model/process_argument.dart';

import '../controller/proc_ffi.dart';

class FmFrameForProcess {
  CameraImage image;
  int? rotation;
  FmProcessArgument? processArgument;
  FmFrameForProcess({
    required this.image,
    this.rotation,
    this.processArgument
  });
}


class Fms2nImagePlane extends ffi.Struct{
  external ffi.Pointer<ffi.Uint8> planeData;
  external ffi.Pointer<Fms2nImagePlane> nextPlane;

  @ffi.Int32()
  external int bytesPerRow;

  @ffi.Int32()
  external int length;

}
class Fms2nImage extends ffi.Struct{
  external ffi.Pointer<Fms2nImagePlane> plane;
  @ffi.Int32()                //0-IOS,1-Android,
  external int platform;
  @ffi.Int32()
  external int width;          //camera image width
  @ffi.Int32()
  external int height;         //camera image height
  @ffi.Int32()
  external int rotation;       //rotation degree of image, get from mobile sensor

//external ffi.Pointer<Fms2nProcessArgument> processArgument;
}

class Fms2nFrameForProcess extends ffi.Struct{
  external ffi.Pointer<Fms2nImage> imageStructPointer;
  external ffi.Pointer<Fms2nProcessArgument> processArgument;
}

extension EfmFrameForProcess on FmFrameForProcess {
  ffi.Pointer<Fms2nFrameForProcess> toFms2nFrameForProcessPointer() {
    ffi.Pointer<Fms2nFrameForProcess> pointer = ffiCreateFrameForProcessP();
    final fms2nFrameForProcess = pointer.ref;
    fms2nFrameForProcess.imageStructPointer =
        image.toFms2nImageP(rotation ?? 0);
    fms2nFrameForProcess.processArgument = processArgument!.toArgumentPointer();
    return pointer;
  }
}