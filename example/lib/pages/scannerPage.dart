import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:pm_opencv_plugin/controller/img_proc_handler.dart';
import 'package:pm_opencv_plugin/convert.dart';
import 'package:pm_opencv_plugin/model/mich_image_model.dart';
import 'package:image/image.dart' as img_lib;
class ScannerPage extends StatefulWidget{
  final List<CameraDescription> ?cameras;
  const ScannerPage({Key? key,required this.cameras}) : super(key: key);

  @override
  _ScannerState  createState()=>_ScannerState();

}

class _ScannerState extends State<ScannerPage>{
  CameraController ?camController;
  OpencvImageProcessor processor=OpencvImageProcessor();
  late OpenCvFramesHandler handler;
  late StreamController<Uint8List> resultStreamController;

  late Timer _timer;
  late bool _isScanBusy;
  late CameraImage _cameraImage;
  bool _isScan=false;
  late Convert conv;
  late img_lib.Image image;
  late Uint8List imgBytesList;
  void startListenStream(Stream<Uint8List> stream) async{
    await for (final result in stream){
      setState(() {
        imgBytesList=result;
        _isScanBusy=false;
        _isScan=true;
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
      resultStreamController = StreamController<Uint8List>();
      startListenStream(resultStreamController.stream);

      handler=OpenCvFramesHandler(processor, resultStreamController);
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
                Image.memory(imgBytesList),
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
                    child: const Text("Start Scanning"),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: ()=>_onPressed(),
                ),
              MaterialButton(
                child: const Text("Stop Scanning"),
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
                    MichFrameForProcess _frameForProcess =
                      MichFrameForProcess(_cameraImage, rotation);
                    await handler.process(_frameForProcess);
                });
                },
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
