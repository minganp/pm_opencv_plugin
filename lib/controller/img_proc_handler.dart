
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pm_opencv_plugin/controller/model_extension.dart';
import 'package:pm_opencv_plugin/controller/processor.dart';
import 'package:pm_opencv_plugin/model/image_model.dart';
import 'package:pm_opencv_plugin/model/process_result.dart';
abstract class Handler <RT>{   //nt for native return type, rt for flutter return type
  StreamController<IProcessResult<RT>> resultStreamController;
  late Future<RT?> Function(FmFrameForProcess imgForProcess) processAsync;
  Handler({required this.resultStreamController});

  IProcessResult<RT> toIProcessResult(RT result);

  Future<RT?> isolateProcess(
      FmFrameForProcess imgForProcess) async
  {
    if(!imgForProcess.image.isEmpty()){
      //print("----here argument::${imgForProcess.processArgument?.pMrzTFD}");
      return compute(
          processAsync,imgForProcess
      );
    }else {
      return null;
    }
  }
  //Should be override by processor if want to prepare argument,or check
  //the argument flower requirement by processor. If not please throw exception
  FmProcessArgument? checkProcessArgument(FmProcessArgument? argument);

  Future<void> process(FmFrameForProcess frame) async {
    try {
      frame.processArgument = checkProcessArgument(frame.processArgument);
    }catch(e){
      throw Exception("ErrCode:-1,Bad Arguments, please check!");
    }
    try {
      final RT? result = await isolateProcess(frame);
      if (result != null) {
        final r = toIProcessResult(result);
        print("will add result. ");
        resultStreamController.add(r);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}

class MrzRectHandler extends Handler<FmMrzOCR2> {
  MrzRectHandler({required super.resultStreamController}) {
    processAsync = mrzRoiProcess;
  }
  @override
  toIProcessResult(FmMrzOCR2 result) {
    IProcessResult<FmMrzOCR2> tResult = IProcessResult<FmMrzOCR2>();
    tResult.errCode = result.errCode;
    tResult.result = result;
    return tResult;
  }

  @override
  FmProcessArgument checkProcessArgument(
      FmProcessArgument? argument) {
    //"mrz.traineddata"
    if (argument == null || argument.pMrzTFD == null ||
        argument.pMrzTF == null) {
      throw Exception("Bad Trained data, please check");
    }
    return argument;
  }
}

class MrzOcrHandler extends Handler<FmMrzOCR> {
  MrzOcrHandler({required super.resultStreamController}){
    processAsync = mrzOcrProcessor;
  }

  @override
  IProcessResult<FmMrzOCR> toIProcessResult(FmMrzOCR result) {
    // TODO: implement toIProcessResult
    IProcessResult<FmMrzOCR> tResult = IProcessResult<FmMrzOCR>();
    tResult.errCode = 0;
    tResult.result = result;
    return tResult;
  }

  @override
  FmProcessArgument checkProcessArgument(
      FmProcessArgument? argument) {
    //"mrz.traineddata"
    if (argument == null || argument.pMrzTFD == null ||
        argument.pMrzTF == null) {
      throw Exception("Bad Trained data, please check");
    }
    return argument;
  }
}

class SimpleImgTrans extends Handler<Uint8List>{
  SimpleImgTrans({required super.resultStreamController}){
   //processAsync = simpleProcessor;
  }

  @override
  IProcessResult<Uint8List> toIProcessResult(Uint8List result) {
    // TODO: implement toIProcessResult
    throw UnimplementedError();
  }

  @override
  FmProcessArgument? checkProcessArgument(FmProcessArgument? argument) {
    // TODO: implement checkProcessArgument
    throw UnimplementedError();
  }
}