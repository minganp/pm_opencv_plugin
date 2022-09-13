
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:ffi' as ffi;
import 'dart:io';
import '../model/mich_image_model.dart';
import 'image_ffi.dart';

extension CameraImageMichExt on CameraImage {
  bool isEmpty() => planes.any((element) => element.bytes.isEmpty);

  ffi.Pointer<MichImage> toMichImagePointer(int rotation) {
    ffi.Pointer<MichImage> pointer = createImg();
    final image = pointer.ref;
    image.width = width;
    image.height = height;
    image.rotation = rotation;

    if(Platform.isIOS){
      image.platform = 0;
      /*-----not implement ----------*/
    }
    if(Platform.isAndroid){
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

      final michImgPlanPointer0 = createImgPlane();
      final michImgPlanPointer1 = createImgPlane();
      final michImgPlanPointer2 = createImgPlane();

      final michImgPlan0 =  michImgPlanPointer0.ref;
      final michImgPlan1 =  michImgPlanPointer1.ref;
      final michImgPlan2 =  michImgPlanPointer2.ref;

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

extension MichImagePointerExt on ffi.Pointer<MichImage>{
  void release(){
    var plane = ref.plane;
    while (plane != ffi.nullptr){
      if (plane.ref.planeData != ffi.nullptr){
        malloc.free(plane.ref.planeData);
      }
      final tmpPlane = plane;
      plane = plane.ref.nextPlane;
      malloc.free(tmpPlane);
    }
    malloc.free(this);
  }
}

extension MichImageMemoryPointerExt on ffi.Pointer<MichImageMemory>{
  Uint8List mapImg2UInt8List(){
    late int size;
    late Uint8List image;
    try {

      size = ref.rtSize[0];
      if (kDebugMode) {
        print("--------from img_proc_handler. returned image size:$size");
      }

      image = ref.rtImg.asTypedList(size);
    }catch(e){
      if (kDebugMode) {
        print(e);
      }
    }
    return image;
  }
  void release(){
    var imgP = ref.rtImg;
    var sizeP = ref.rtSize;
    if(imgP != ffi.nullptr) {
      if(imgP !=ffi.nullptr) {
        malloc.free(imgP);
      }
    }
    if(sizeP != ffi.nullptr) {
      if(sizeP !=ffi.nullptr) {
        malloc.free(sizeP);
      }
    }
    malloc.free(this);
  }
}
