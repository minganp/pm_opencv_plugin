/*
  naming scheme

   Ep2n extension on Pointer to native
   Es2n extension on struct to native
   Fms2n flutter model extension on ffi.struct to native
   Fm    flutter model
   Efm   extension of flutter model
 */

import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:pm_opencv_plugin/Exception/exception.dart';
import 'package:pm_opencv_plugin/controller/proc_ffi.dart';
import 'package:pm_opencv_plugin/mrz_parser-master/lib/mrz_parser.dart';

import '../model/image_model.dart';

extension Ep2nImagePointerExt on ffi.Pointer<Fms2nImage> {
  void release() {
    var plane = ref.plane;
    while (plane != ffi.nullptr) {
      if (plane.ref.planeData != ffi.nullptr) {
        malloc.free(plane.ref.planeData);
      }
      final tmpPlane = plane;
      plane = plane.ref.nextPlane;
      malloc.free(tmpPlane);
    }
    malloc.free(this);
  }
}

extension Ep2nProcessArgument on ffi.Pointer<Fms2nProcessArgument> {
  void release() {
    malloc.free(ref.pMrzTFD);
    malloc.free(ref.pMrzTF);
  }
}

extension Ep2nFrameForProcess on ffi.Pointer<Fms2nFrameForProcess> {
  void release() {
    if (ref.imageStructPointer != ffi.nullptr) ref.imageStructPointer.release();
    if (ref.processArgument != ffi.nullptr) ref.processArgument.release();
  }
}

extension EpfnImage on ffi.Pointer<FmsfnImage> {
  Uint8List? mapImg2UInt8List() {
    late int size;
    late Uint8List image;
    try {
      size = ref.rtSize[0];
      image = ref.rtImg.asTypedList(size);
    } catch (e){throw Exception(e);}
    return image;
  }

  void release() {
    var imgP = ref.rtImg;
    var sizeP = ref.rtSize;
    if (imgP != ffi.nullptr) {
      malloc.free(imgP);
    }
    if (sizeP != ffi.nullptr) {
      malloc.free(sizeP);
    }
    malloc.free(this);
  }
}

extension EpfnMrzOCR on ffi.Pointer<FmsfnMrzOCR> {
  Uint8List? mapImg2ui8list() {
    Uint8List? uInt8ListImg;
    try{
      uInt8ListImg = ref.imgMrzRoi.mapImg2UInt8List();
    }catch(e){
      throw PmExceptionEx(-105,e.toString());
    }
    return uInt8ListImg;
  }

  MRZResult? parseMrz(){
    MRZResult? result;
    var ocrTxt = ref.passportText.toDartString();
    if (ocrTxt.endsWith("\n")) ocrTxt = ocrTxt.substring(0, ocrTxt.length - 1);
    print("passportString:${ref.passportText.toDartString()}");
    List<String> ocrTxtArr = ocrTxt.split("\n");

    try {
      print("before tryParse");
      print("$ocrTxtArr");
      result = MRZParser.tryParse(ocrTxtArr);
      if(result == null)throw PmException(-202);
      return result;
    } on MRZException catch (e) {
      throw PmExceptionEx(-201,e.toString());
    } catch(e){
      throw PmExceptionEx(-203,e.toString());
    }
  }

  void release() {
    var imgPointer = ref.imgMrzRoi;
    var txtPointer = ref.passportText;
    if (imgPointer != ffi.nullptr) {
      imgPointer.release();
    }
    if (txtPointer != ffi.nullptr) {
      malloc.free(txtPointer);
    }
    if (this != ffi.nullptr) {
      malloc.free(this);
    }
  }
}

extension EpfnMrzRect on ffi.Pointer<FmsfnRect> {
  Rectangle toFluRectangle() {
    Rectangle roiRect = Rectangle(ref.x, ref.y, ref.width, ref.height);
    return roiRect;
  }

  void release() {
    malloc.free(this);
  }
}

extension EpfnMrzOCR2 on ffi.Pointer<FmsfnMrzOCR2> {
  Future<FmMrzOCR2> toMrzResult() async {
    Rectangle rectRoi = ref.roiRect.toFluRectangle();
    int errCode = ref.errCode;
    MRZResult? mrzResult;
    if (ref.errCode >= 0) {
      try {
        List<String> rawArr = ref.rawOcrTxt.toDartString().split("\n");
        mrzResult = MRZParser.tryParse(rawArr)!;
      } catch (e) {
        mrzResult = null;
        return FmMrzOCR2(rectRoi, mrzResult, -2);
      }
    } else {
      mrzResult = null;
    }
    return FmMrzOCR2(rectRoi, mrzResult, errCode);
  }

  void release() {
    var rectRoi = ref.roiRect;
    var txtPointer = ref.rawOcrTxt;
    if (rectRoi != ffi.nullptr) {
      rectRoi.release();
    }
    if (txtPointer != ffi.nullptr) {
      malloc.free(txtPointer);
    }
    if (this != ffi.nullptr) {
      malloc.free(this);
    }
  }
}

extension EfmProcessArgument on FmProcessArgument {
  ffi.Pointer<Fms2nProcessArgument> toArgumentPointer() {
    ffi.Pointer<Fms2nProcessArgument> argumentPointer = ffiCreateArgumentP();
    final argumentP = argumentPointer.ref;
    argumentP.pMrzTFD = pMrzTFD!.toNativeUtf8();
    argumentP.pMrzTF = pMrzTF!.toNativeUtf8();
    return argumentPointer;
  }
}

extension EfmCameraImage on CameraImage {
  bool isEmpty() => planes.any((element) => element.bytes.isEmpty);

  ffi.Pointer<Fms2nImage> toFms2nImageP(int rotation) {
    ffi.Pointer<Fms2nImage> pointer = ffiCreateImgP();
    final image = pointer.ref;
    image.width = width;
    image.height = height;
    image.rotation = rotation;
    if (Platform.isIOS) {
      image.platform = 0;
      /*-----not implement ----------*/
    }
    if (Platform.isAndroid) {
      image.platform = 1;
      final plane0 = planes[0];
      final pLen0 = plane0.bytes.length;
      final bytesPerRow0 = plane0.bytesPerRow;

      final plane1 = planes[1];
      final pLen1 = plane1.bytes.length;
      final bytesPerRow1 = plane1.bytesPerRow;

      final plane2 = planes[2];
      final pLen2 = plane2.bytes.length;
      final bytesPerRow2 = plane2.bytesPerRow;

      final p0 = malloc.allocate<ffi.Uint8>(pLen0);
      final p1 = malloc.allocate<ffi.Uint8>(pLen1);
      final p2 = malloc.allocate<ffi.Uint8>(pLen2);

      final pointerList0 = p0.asTypedList(pLen0);
      final pointerList1 = p1.asTypedList(pLen1);
      final pointerList2 = p2.asTypedList(pLen2);

      pointerList0.setRange(0, pLen0, plane0.bytes);
      pointerList1.setRange(0, pLen1, plane1.bytes);
      pointerList2.setRange(0, pLen2, plane2.bytes);

      final michImgPlanPointer0 = ffiCreateImgPlaneP();
      final michImgPlanPointer1 = ffiCreateImgPlaneP();
      final michImgPlanPointer2 = ffiCreateImgPlaneP();

      final michImgPlan0 = michImgPlanPointer0.ref;
      final michImgPlan1 = michImgPlanPointer1.ref;
      final michImgPlan2 = michImgPlanPointer2.ref;

      michImgPlan2.bytesPerRow = bytesPerRow2;
      michImgPlan2.length = pLen2;
      michImgPlan2.nextPlane = ffi.nullptr;
      michImgPlan2.planeData = p2;
      michImgPlan1.nextPlane = michImgPlanPointer2;

      michImgPlan1.bytesPerRow = bytesPerRow1;
      michImgPlan1.length = pLen1;
      michImgPlan1.planeData = p1;
      michImgPlan0.nextPlane = michImgPlanPointer1;

      michImgPlan0.bytesPerRow = bytesPerRow0;
      michImgPlan0.length = pLen0;
      michImgPlan0.planeData = p0;

      image.plane = michImgPlanPointer0;
    }
    return pointer;
  }
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
