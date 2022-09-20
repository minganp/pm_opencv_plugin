import 'dart:async';
import 'dart:typed_data';
import 'dart:ffi' as ffi;

import 'package:flutter/foundation.dart';
import 'package:pm_opencv_plugin/controller/camera_img_ext.dart';
import 'package:pm_opencv_plugin/model/mich_image_model.dart';
import 'package:pm_opencv_plugin/pm_opencv_plugin.dart';
import 'image_ffi.dart';

abstract class FrameHandler<T>{
  abstract StreamController<T> resultStreamController;
  Future<void> process(MichFrameForProcess img);
}

class OpenCvFramesHandler extends FrameHandler<Uint8List>{
  MichProcessor processor = MichProcessor();
  @override
  StreamController<Uint8List> resultStreamController;

  OpenCvFramesHandler(this.resultStreamController);

  @override
  Future<void> process(MichFrameForProcess img) async{
    print("Begin to process");
    final Uint8List imgU8list = await processor.procImgWithOpencv(img);
    resultStreamController.add(imgU8list);
  }
}

class MrzHandler extends FrameHandler<MrzResult>{
  MichProcessor processor = MichProcessor();
  @override
  StreamController<MrzResult> resultStreamController;

  MrzHandler(this.resultStreamController);

  @override
  Future<void> process(MichFrameForProcess img) async{
    final MrzResult result =  await processor.procImgOcr(img);
    resultStreamController.add(result);
  }
}

class MichProcessor{
  final _ocrPlugin = PmOpencvPlugin();

  Future<Uint8List> _processFrameAsync(MichFrameForProcess frame) async{
    try{
      final stopwatch = Stopwatch()..start();
      ffi.Pointer<MichImage> imgRaw =
        frame.image.toMichImagePointer(frame.rotation);

      //ffi.Pointer<ffi.Uint8> p= malloc.allocate(3*frame.image.width*frame.image.height);
      //ffi.Pointer<ffi.Uint32> s = malloc.allocate(1);
      print('----img raw address: ${imgRaw.address}');
      //ffi.Pointer<MichImageMemory> imgRt=processNativeImg(imgRaw);
      ffi.Pointer<MichImageMemory> imgRt=roiStepByStep(imgRaw);
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
  Future<MrzResult> _getMrzInFrame(MichFrameForProcess frame) async{
    Uint8List imgBytes = await _processFrameAsync(frame);
    String? text = await _ocrPlugin.imageToText(imgBytes);
    return MrzResult(imgBytes,text!);
  }
  Future<Uint8List> procImgWithOpencv(MichFrameForProcess imgForProcess) async{
    if(!imgForProcess.image.isEmpty()){
      return compute(
          _processFrameAsync, imgForProcess
      );
    }else {
      return Uint8List(0);
    }
  }

  Future<MrzResult> procImgOcr(MichFrameForProcess imgForProcess) async {
    if(!imgForProcess.image.isEmpty()){
      return compute(
          _getMrzInFrame, imgForProcess
      );
    }else{
      return MrzResult(Uint8List(0), '');
    }
  }
}

class MrzResult{
  Uint8List imgBytes;
  String ocrText;

  MrzResult(this.imgBytes,this.ocrText);
}