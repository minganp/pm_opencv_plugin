
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pm_opencv_plugin/bloc_center/controller/mrz_ocr_controller.dart';
import 'package:pm_opencv_plugin/model/image_model.dart';
import 'package:pm_opencv_plugin_example/util/util.dart';
import 'package:pm_opencv_plugin/mrz_parser-master/lib/mrz_parser.dart';
import '../widget/document_stack.dart';
import '../widget/passportModal.dart';

class ScannerPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final String? trainedDataPath;

  const ScannerPage(
      {Key? key, required this.cameras, required this.trainedDataPath})
      : super(key: key);

  @override
  ScannerState createState() => ScannerState();
}

class ScannerState extends State<ScannerPage> {
  CameraController? camController;

  FmMrzOCR? mrzResult;
  bool beginScan = false;
  bool scanFinished = false;

  double timeOutInSeconds = 10;
  int scanFreqMilliseconds = 100;
  late FmProcessArgument argument;

  late MrzProcessController processController;

  void onScanSucceed(FmMrzOCR result) {
    print("result: ${result.ocrText!.documentNumber}");
    setState(() {
      mrzResult = result;
      scanFinished = true;
      beginScan = false;
      _showPassModal(result.ocrText!);
    });
  }

  void onScanFailed(FmMrzOCR result) async {
    print("process failed");
    setState(() {
      mrzResult = result;
      scanFinished = true;
      beginScan = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    camController =
        CameraController(widget.cameras![0], ResolutionPreset.medium);
    camController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      print("--is cameraController null?${camController == null}");

      processController = MrzProcessController(
          camController: camController!,
          timeOutSeconds: timeOutInSeconds,
          scanFreqMilliseconds: scanFreqMilliseconds,
          onSuccessCallback: onScanSucceed,
          onFailCallback: onScanFailed);
      argument = FmProcessArgument();
      argument.pMrzTFD = widget.trainedDataPath;
      //processController.startProcess(argument);
      setState(() {});
    });
  }

  @override
  void dispose() {
    camController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Size size = MediaQuery.of(context).size;

    return Material(
        color: Colors.black,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              alignment: Alignment.bottomCenter,
              color: Colors.black,
              padding: const EdgeInsets.only(bottom: 20.0),
              height: 150,
              child: _scanStartButton(_onScanBtnPressed)),
          Container(
              width: size.width,
              height: size.width * 1.33,
              color: Colors.black,
              child: scanFinished? Image.memory(mrzResult!.imgBytes)
                  :Stack(children: [
                //scanStack(size.width, size.width*1.33),
                CameraPreview(camController!),
                scanAux(size.width, size.width * 1.33),
                ScanLine(
                  height: size.width * 1.33,
                  width: size.width,
                  startOr: beginScan,
                ),
              ])),
          const Expanded(
            child: Text("Hi"),
          ),
        ]));
  }

  void _beginToScan() async {
    FmProcessArgument argument = FmProcessArgument();
    argument.pMrzTFD = widget.trainedDataPath;
    argument.pMrzTF = "mrz.trainedData";
    processController.startProcess(argument);
    setState(() {
      beginScan = true;
    });
  }

  Function? _onScanBtnPressed() {
    if (beginScan) {
      return null;
    } else {
      return () {
        _beginToScan();
      };
    }
  }

  Widget _scanStartButton(Function onPressed) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          color: beginScan ? Colors.grey : Colors.white,
          border: Border.all(width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(50))),
      child: TextButton(
          onPressed: onPressed(),
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              "Start",
              style: GoogleFonts.getFont(
                'Lato',
                fontSize: 16,
                color: Colors.black,
                decorationThickness: 0,
              ),
            ),
          )),
    );
  }

  Widget scanAux(double width, double height) {
    String auxiliaryWords = "<".multiChar(44);

    return Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Container(
            width: width,
            height: height,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              border: Border(
                top: BorderSide(width: 2.0, color: Colors.grey),
                left: BorderSide(width: 2.0, color: Colors.grey),
                right: BorderSide(width: 2.0, color: Colors.grey),
                bottom: BorderSide(width: 2.0, color: Colors.grey),
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  auxiliaryWords,
                  style: GoogleFonts.getFont(
                    'Lato',
                    fontSize: 16,
                    color: Colors.grey,
                    decorationThickness: 0,
                  ),
                ),
              ),
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  auxiliaryWords,
                  style: GoogleFonts.getFont(
                    'Lato',
                    fontSize: 16,
                    color: Colors.grey,
                    decorationThickness: 0,
                  ),
                ),
              ),
            ])));
  }

  Widget _cameraPreviewWidget() {
    if (camController == null || !camController!.value.isInitialized) {
      return const Text('Tap a camera',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ));
    } else {
      return AspectRatio(
        aspectRatio: camController!.value.aspectRatio,
        child: CameraPreview(camController!),
      );
    }
  }

  void _showPassModal(MRZResult result) {
    showCupertinoModalPopup(
        context: context, builder: (context) => passModal(context, result));
  }
}