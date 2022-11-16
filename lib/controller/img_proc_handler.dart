import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pm_opencv_plugin/Exception/exception.dart';
import 'package:pm_opencv_plugin/controller/model_extension.dart';
import 'package:pm_opencv_plugin/controller/processor.dart';
import 'package:pm_opencv_plugin/model/image_model.dart';
import 'package:pm_opencv_plugin/model/process_result.dart';

import '../model/frame_for_process.dart';
import '../model/process_argument.dart';
import 'processor/mrz_json_image_processor.dart';

abstract class Handler<RT> {
  //nt for native return type, rt for flutter return type
  StreamController<IProcessResult<RT>> resultStreamController;
  late Future<IProcessResult<RT>> Function(FmFrameForProcess imgForProcess)
      processAsync;

  Handler({required this.resultStreamController});

  Future<IProcessResult<RT>> isolateProcess(
      FmFrameForProcess imgForProcess) async {
    if (imgForProcess.image.isEmpty()) throw PmException(-98);
    return compute(processAsync, imgForProcess);
  }

  //Should be override by processor if want to prepare argument,or check
  //the argument flower requirement by processor. If not please throw exception
  FmProcessArgument? checkProcessArgument(FmProcessArgument? argument);

  Future<void> process(FmFrameForProcess frame) async {
    IProcessResult<RT> rt;
    try {
      frame.processArgument = checkProcessArgument(frame.processArgument);
    } on PmException catch (e) {
      rt = IProcessResult.failed(ec: e.errCode);
      resultStreamController.add(rt);
      return;
    } catch (e) {
      rt = IProcessResult.failed(ec: -99, eMsg: e.toString());
      resultStreamController.add(rt);
      return;
    }
    try {
      rt = await isolateProcess(frame);
      //rt = toIProcessResult(result);
    } on PmException catch (e) {
      rt = IProcessResult.failed(ec: e.errCode);
    } on PmExceptionEx catch (e) {
      rt = IProcessResult.failed(ec: e.errCode, eMsg: e.exMsg);
    } catch (e) {
      print("err in call native:${e.toString()}");
      rt = IProcessResult.failed(ec: -104, eMsg: e.toString());
    }
    resultStreamController.add(rt);
    return;
  }
}

class MrzRectHandler extends Handler<FmMrzOCR2> {
  MrzRectHandler({required super.resultStreamController}) {
    processAsync = mrzRoiProcess;
  }

  @override
  FmProcessArgument checkProcessArgument(FmProcessArgument? argument) {
    //"mrz.traineddata"
    if (argument == null ||
        argument.pMrzTFD == null ||
        argument.pMrzTF == null) {
      throw PmException(-99);
    }
    return argument;
  }
}

class MrzOcrHandler extends Handler<FmMrzOCR> {
  MrzOcrHandler({required super.resultStreamController}) {
    processAsync = mrzOcrImgProcessor;
  }

  @override
  FmProcessArgument checkProcessArgument(FmProcessArgument? argument) {
    //"mrz.traineddata"
    if (argument == null ||
        argument.pMrzTFD == null ||
        argument.pMrzTF == null) {
      throw PmException(-99);
    }
    return argument;
  }
}

class MrzJsonHandler extends Handler<FmMrzJson> {
  MrzJsonHandler({required super.resultStreamController}) {
    processAsync = mrzJsonProcessor;
  }

  @override
  FmProcessArgument checkProcessArgument(FmProcessArgument? argument) {
    //"mrz.traineddata"
    if (argument == null ||
        argument.pMrzTFD == null ||
        argument.pMrzTF == null) {
      throw PmException(-99);
    }
    return argument;
  }
}

class SimpleImgTrans extends Handler<Uint8List> {
  SimpleImgTrans({required super.resultStreamController}) {
    //processAsync = simpleProcessor;
  }

  @override
  FmProcessArgument? checkProcessArgument(FmProcessArgument? argument) {
    // TODO: implement checkProcessArgument
    throw UnimplementedError();
  }
}

/*

1[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, EE72876565CHN7102132M2811257MFONMDPHLALCA928]
0[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, FE72876565CHN7102132M2811257MFONNDPHLALCA928]
0[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, FE72876565CHN7102132M2811257MFONHDPHLALCA928]
1[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, EE72876565CHN7102132M2811257MFONMDPHLALCA928]
1[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, EE72876565CHN7102132M2811257MFONMDPHLALCA928]
0[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, EE72876565CHN7102132M2811257MFONNDPHLALCA928]
1[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, EE72876565CHN7102132M2811257MFONMDPHLALCA928]
1[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, EE72876565CHN7102132M2811257MFONMDPHLALCA928]
1[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, EE72876565CHN7102132M2811257MFONMDPHLALCA928]
0[POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<, EE72876565CHN7102132M2811257MFONMDPHLALCA928]
EE72876565CHN7102132M2811257MFONMDPHLALCA928
FE72876565CHN7102132M2811257MFONNDPHLALCA928
EE72876565CHN7102132M2811257MFONHDPHLALCA928
POCHNPENG<<MINGAN<<<<<<<<<<<<<<<<<<<<<<<<<<<,

 */
