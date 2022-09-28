/*
  naming scheme

   Ep2n extension on Pointer to native
   Es2n extension on struct to native
   Fms2n flutter model extension on ffi.struct to native
   Fm    flutter model
   Fmsfn flutter model struct from native
   Efm   extension of flutter model
 */

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'dart:ffi' as ffi;


class Fms2nProcessArgument extends ffi.Struct{
  external ffi.Pointer<Utf8> pMrzTFD; //directory of passport mrz trained file directory
  external ffi.Pointer<Utf8> pMrzTF; //directory of passport mrz trained file
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

class FmsfnImage extends ffi.Struct{
  external ffi.Pointer<ffi.Uint8> rtImg;    //returned Image of UInt8List
  external ffi.Pointer<ffi.Uint32> rtSize;  //size of image
}
class FmsfnRect extends ffi.Struct{
  @ffi.Int32()
  external int x;

  @ffi.Int32()
  external int y;

  @ffi.Int32()
  external int width;

  @ffi.Int32()
  external int height;
}
class FmsfnMrzOCR extends ffi.Struct{
  external ffi.Pointer<FmsfnImage> imgMrzRoi;
  external ffi.Pointer<Utf8> passportText;
}


class FmProcessArgument {
  String? pMrzTFD; //directory of passport mrz trained file directory
  String? pMrzTF; //directory of passport mrz trained file}

  FmProcessArgument({this.pMrzTFD, this.pMrzTF});
}
class FmMrzOCR{
  Uint8List imgBytes;
  String ocrText;
  late Duration processDur;
  FmMrzOCR(this.imgBytes,this.ocrText);
}
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