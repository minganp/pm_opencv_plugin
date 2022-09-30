import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:pm_opencv_plugin/controller/img_proc_handler.dart';
import 'package:pm_opencv_plugin/convert.dart';
import 'package:pm_opencv_plugin/model/image_model.dart';
import 'package:image/image.dart' as img_lib;
import 'package:pm_opencv_plugin_example/main.dart';

class ScannerPage extends StatefulWidget{
  final List<CameraDescription> ?cameras;
  final String ?trainedDataPath;
  const ScannerPage({Key? key,required this.cameras,required this.trainedDataPath}) : super(key: key);

  @override
  _ScannerState  createState()=>_ScannerState();

}

class _ScannerState extends State<ScannerPage>{
  CameraController ?camController;
  //OpencvImageProcessor processor=OpencvImageProcessor();
  //late OpenCvFramesHandler handler;
  late MrzOcrHandler handler;
  //late StreamController<Uint8List> resultStreamController;
  late StreamController<FmMrzOCR> mrzStreamController;
  late Timer _timer;
  late bool _isScanBusy;
  late CameraImage _cameraImage;
  bool _isScan=false;
  late Convert conv;
  late img_lib.Image image;
  late Uint8List imgBytesList;
  String? textInImage;
  void startListenStream(Stream<FmMrzOCR> stream) async{
    await for (final result in stream){
      setState(() {
        imgBytesList = result.imgBytes;
        _isScanBusy = false;
        _isScan = true;
        textInImage = result.ocrText;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _isScanBusy=false;
    camController=CameraController(widget.cameras![0], ResolutionPreset.medium);
    camController!.initialize().then((_){
      if(!mounted){
        return;
      }
      //resultStreamController = StreamController<Uint8List>();
      mrzStreamController = StreamController<FmMrzOCR>();
      startListenStream(mrzStreamController.stream);
      //handler=OpenCvFramesHandler(processor, resultStreamController);
      handler = MrzOcrHandler(resultStreamController: mrzStreamController);
      setState(() {_isScan=false;});
    });
  }
  
  @override
  void dispose(){
    
    camController?.dispose();
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
        children: [
            _isScan?
            Expanded(
              child: /*Image.memory(Uint8List.fromList(img_lib.encodeJpg(image)))*/
                //Image.memory(Uint8List.fromList(img_lib.encodeJpg(image))),
              Column(
                children: [
                  Image.memory(imgBytesList),
                  Text(textInImage!),
                ],
              ),
            ):
            Expanded(child: _cameraPreviewWidget()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text("aaa",style: TextStyle(fontStyle: FontStyle.italic,fontSize: 34)),
            ],
          ),
          Container(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
                MaterialButton(
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: ()=>_onPressed(),
                    child: const Text("Start Scanning"),
                ),
              MaterialButton(
                textColor: Colors.white,
                color: Colors.red,
                onPressed: ()async{
                  //_timer.cancel();
                  if(_isScanBusy)return;
                  _isScanBusy=true;
                  await Future.delayed(const Duration(microseconds: 200),()async{
                    print("Scan finished!--------image info: "
                        "${_cameraImage.width},"
                        "${_cameraImage.width},"
                        "${_cameraImage.format.group.name}");
                    await camController!.stopImageStream();
                    //image=camImg2UInt8Img(_cameraImage);
                    //imgBytesList=camImg2UInt8Img2(_cameraImage);
                    int rotation=0;

                    FmFrameForProcess frameForProcess = FmFrameForProcess(
                        image: _cameraImage,
                        rotation: 0,
                        processArgument: FmProcessArgument(
                            pMrzTFD:widget.trainedDataPath,
                            pMrzTF:"mrz.traineddata"
                        )
                    );
                    frameForProcess.image = _cameraImage;
                    frameForProcess.rotation = rotation;
                    //FmFrameForProcess(image:_cameraImage, rotation: rotation);
                    await handler.process(frameForProcess);
                });
                },
                child: const Text("Stop Scanning"),
              ),
            ],
            ),
          )
        ],
    );
  }

  //begin scan
  void _onPressed() async {
    setState((){
      _isScan=false;
    });
    await camController!.startImageStream((CameraImage availableImage) async{
        _cameraImage=availableImage;
    });
  }


  Widget _cameraPreviewWidget(){
    if(camController ==null || !camController!.value.isInitialized){
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ));
    }else{
        return AspectRatio(
            aspectRatio: camController!.value.aspectRatio,
            child: CameraPreview(camController!),
        );
    }
  }
}
