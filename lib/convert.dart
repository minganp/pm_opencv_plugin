import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
//import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img_lib;

// C function signatures
typedef CConvertFunc = ffi.Pointer<ffi.Uint32> Function(
    ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>,
    ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32,
    );
typedef CCYuv2UInt8ListFunc = ffi.Void Function(
    ffi.Pointer<ffi.Uint8>, ffi.Int32,
    ffi.Pointer<ffi.Uint8>, ffi.Int32,ffi.Int32,
    ffi.Pointer<ffi.Uint8>,ffi.Int32, ffi.Int32,
    ffi.Int32,ffi.Int32,ffi.Int32,
    ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Uint32>
    );
typedef CCYuv2UInt8ListFunc2 = ffi.Void Function(
    ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Uint32>
    );
// Dart function signatures
typedef Convert = ffi.Pointer<ffi.Uint32> Function(
    ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>, ffi.Pointer<ffi.Uint8>,
    int, int, int, int
    );
typedef ConvertYuv2UInt8List = void Function(
    ffi.Pointer<ffi.Uint8>, int,
    ffi.Pointer<ffi.Uint8>, int,int,
    ffi.Pointer<ffi.Uint8>,int, int,
    int,int,int,
    ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Uint32>
    );
typedef ConvertYuv2UInt8List2 =void Function(
    ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Uint32>
    );

ffi.DynamicLibrary _openDynamicLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libOpenCV_ffi.so');
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open("main.dll");
  }

  return ffi.DynamicLibrary.process();
}

ffi.DynamicLibrary _lib = _openDynamicLibrary();

final Convert _conv = _lib
      .lookup<ffi.NativeFunction<CConvertFunc>>('convertImage')
      .asFunction();

final ConvertYuv2UInt8List _con8 = _lib
      .lookup<ffi.NativeFunction<CCYuv2UInt8ListFunc>>("convertTestAndroid")
      .asFunction();

final ConvertYuv2UInt8List2 _con82 = _lib
    .lookup<ffi.NativeFunction<CCYuv2UInt8ListFunc2>>("convertTestAndroid2")
    .asFunction();
//convert camera YUN420 to Image
img_lib.Image camImg2UInt8Img(CameraImage img){
  late img_lib.Image image;
  if(Platform.isAndroid){
    ffi.Pointer<ffi.Uint8> p = calloc(img.planes[0].bytes.length);
    ffi.Pointer<ffi.Uint8> p1 = calloc(img.planes[1].bytes.length);
    ffi.Pointer<ffi.Uint8> p2 = calloc(img.planes[2].bytes.length);

    Uint8List pointerList = p.asTypedList(img.planes[0].bytes.length);
    Uint8List pointerList1 = p1.asTypedList(img.planes[1].bytes.length);
    Uint8List pointerList2 = p2.asTypedList(img.planes[2].bytes.length);
    pointerList.setRange(0, img.planes[0].bytes.length, img.planes[0].bytes);
    pointerList1.setRange(0, img.planes[1].bytes.length, img.planes[1].bytes);
    pointerList2.setRange(0, img.planes[2].bytes.length, img.planes[2].bytes);

    // Call the convertImage function and convert the YUV to RGB
    ffi.Pointer<ffi.Uint32> imgP = _conv(p, p1, p2, img.planes[1].bytesPerRow,
        img.planes[1].bytesPerPixel!, img.planes[0].bytesPerRow, img.height);
    // Get the pointer of the data returned from the function to a List
    List<int> imgData = imgP.asTypedList((img.planes[0].bytesPerRow * img.height));
    // Generate image from the converted data
    image = img_lib.Image.fromBytes(img.height, img.planes[0].bytesPerRow, imgData);

    calloc.free(p);
    calloc.free(p1);
    calloc.free(p2);
    calloc.free(imgP);
  }else if(Platform.isIOS){
    image = img_lib.Image.fromBytes(
        img.planes[0].bytesPerRow,
        img.height,
        img.planes[0].bytes,
        format: img_lib.Format.bgra
    );
  }
  return image;
}

Uint8List camImg2UInt8Img2(CameraImage img){
  //late img_lib.Image image;
  late Uint8List imgUBytes;
  //late List<int> imgData;
  late ffi.Pointer<ffi.Uint8> rtImg;
  if(Platform.isAndroid){
    ffi.Pointer<ffi.Uint8> p = calloc(img.planes[0].bytes.length);
    ffi.Pointer<ffi.Uint8> p1 = calloc(img.planes[1].bytes.length);
    ffi.Pointer<ffi.Uint8> p2 = calloc(img.planes[2].bytes.length);

    Uint8List pointerList = p.asTypedList(img.planes[0].bytes.length);
    Uint8List pointerList1 = p1.asTypedList(img.planes[1].bytes.length);
    Uint8List pointerList2 = p2.asTypedList(img.planes[2].bytes.length);
    pointerList.setRange(0, img.planes[0].bytes.length, img.planes[0].bytes);
    pointerList1.setRange(0, img.planes[1].bytes.length, img.planes[1].bytes);
    pointerList2.setRange(0, img.planes[2].bytes.length, img.planes[2].bytes);

    int bytesPerRow0=img.planes[0].bytesPerRow;
    int length1=img.planes[1].bytes.length;
    int bytesPerRow1=img.planes[1].bytesPerRow;
    int length2=img.planes[2].bytes.length;
    int bytesPerRow2=img.planes[2].bytesPerRow;
    int height=img.height;
    int width=img.width;
    int orientation=0;
    // Call the convertImage function and convert the YUV to RGB
    rtImg=malloc.allocate(height*width);

    ffi.Pointer<ffi.Uint32> s= malloc.allocate(1);
    s[0]= img.planes[0].bytes.length;
    rtImg
        .asTypedList(s[0])
        .setRange(0, s[0], img.planes[0].bytes);

    _con8(
        p,bytesPerRow0,
        p1, length1,bytesPerRow1,
        p2, length2,bytesPerRow2,
        width,height,orientation,
        rtImg,s
        );
    // Get the pointer of the data returned from the function to a List
    imgUBytes=rtImg.asTypedList(s[0]);
    // Generate image from the converted data
    //image = img_lib.Image.fromBytes(img.height, img.planes[0].bytesPerRow, imgData);

    calloc.free(p);
    calloc.free(p1);
    calloc.free(p2);
    calloc.free(rtImg);
    calloc.free(s);
  }else if(Platform.isIOS){
    /*
    image = img_lib.Image.fromBytes(
        img.planes[0].bytesPerRow,
        img.height,
        img.planes[0].bytes,
        format: img_lib.Format.bgra
    );
     */
  }


  return imgUBytes;
}

Uint8List camImg2UInt8Image22(CameraImage img){
  ffi.Pointer<ffi.Uint32> s = malloc.allocate(1);
  s[0] = img.planes[0].bytes.length;
  ffi.Pointer<ffi.Uint8> p = malloc.allocate(3 *
      img.height*img.width
  );
  p.asTypedList(s[0])
      .setRange(0, s[0], img.planes[0].bytes);
  _con82(p,s);
  Uint8List pList=p.asTypedList(s[0]);
  malloc.free(p);
  malloc.free(s);
  return pList;
}