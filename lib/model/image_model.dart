/*
  naming scheme

   Ep2n extension on Pointer to native
   Es2n extension on struct to native
   Fms2n flutter model extension on ffi.struct to native
   Fm    flutter model
   Fmsfn flutter model struct from native
   Efm   extension of flutter model
 */

import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:pm_opencv_plugin/model/process_argument.dart';
import 'dart:ffi' as ffi;
import 'package:pm_opencv_plugin/mrz_parser-master/lib/mrz_parser.dart';

import 'mrz.dart';


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
class FmsfnMrzOCR2 extends ffi.Struct{
  external ffi.Pointer<FmsfnRect> roiRect;
  external ffi.Pointer<Utf8> rawOcrTxt;
  @ffi.Int32()
  external int errCode;
}
class FmsfnMrzJson extends ffi.Struct{
  external ffi.Pointer<ffi.Char> mrzJsonStr;
}


class FmMrzOCR {
  Uint8List? imgBytes;
  Mrz? mrz;
  late Duration processDur;
  FmMrzOCR(this.imgBytes,this.mrz);
}
class FmMrzJson{
  Mrz? mrz;
  late Duration? processDur;
  FmMrzJson(this.mrz);
}
class FmMrzOCR2 {
  //rece of roi
  Rectangle roiRect;

  MRZResult? passResult;

  //0: success, -1: training data error, -2: recognition error, -3: roi error
  int errCode;

  //process duration
  late Duration processDur;
  FmMrzOCR2(this.roiRect,this.passResult,this.errCode);
}
