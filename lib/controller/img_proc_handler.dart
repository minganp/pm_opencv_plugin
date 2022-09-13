import 'dart:async';
import 'dart:typed_data';
import 'dart:ffi' as ffi;

import 'package:flutter/foundation.dart';
import 'package:pm_opencv_plugin/controller/camera_img_ext.dart';
import 'package:pm_opencv_plugin/model/mich_image_model.dart';

import 'image_ffi.dart';

abstract class FrameHandler<T>{
  abstract StreamController<T> resultStreamController;
  Future<void> process(MichFrameForProcess img);
}

class OpenCvFramesHandler extends FrameHandler<Uint8List>{
  OpencvImageProcessor processor;
  @override
  StreamController<Uint8List> resultStreamController;

  OpenCvFramesHandler(this.processor,this.resultStreamController);

  @override
  Future<void> process(MichFrameForProcess img) async{
    print("Begin to process");
    final Uint8List imgU8list = await processor.procImgWithOpencv(img);
    resultStreamController.add(imgU8list);
  }


}

class OpencvImageProcessor{

  Future<Uint8List> processFrameAsync(MichFrameForProcess frame) async{
    try{
      final stopwatch = Stopwatch()..start();
      ffi.Pointer<MichImage> imgRaw =
        frame.image.toMichImagePointer(frame.rotation);

      //ffi.Pointer<ffi.Uint8> p= malloc.allocate(3*frame.image.width*frame.image.height);
      //ffi.Pointer<ffi.Uint32> s = malloc.allocate(1);
      print('----img raw address: ${imgRaw.address}');
      ffi.Pointer<MichImageMemory> imgRt=processNativeImg(imgRaw);
      //processNativeImg2(imgRaw,p,s);
      print('----Trans image in ${stopwatch.elapsedMilliseconds} ms');
      stopwatch.stop();
      print("---- image returned back from opencv1");

      //print("------size:${s[0]}");

      final img = imgRt.mapImg2UInt8List();
      //final img = p.asTypedList(s[0]);
      imgRaw.release();
      imgRt.release();
      //malloc.free(p);
      //malloc.free(s);
      print("---- image returned back from opencv");
      return img;
    }catch(e){
      print(e);
    }
    return Uint8List(0);
  }
  Future<Uint8List> procImgWithOpencv(MichFrameForProcess imgForProcess) async{
    if(!imgForProcess.image.isEmpty()){
      return compute(
          processFrameAsync, imgForProcess
      );
    }else {
      return Uint8List(0);
    }
  }
}