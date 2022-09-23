import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
class MichImage extends ffi.Struct{
  external ffi.Pointer<MichImagePlane> plane;
  @ffi.Int32()                //0-IOS,1-Android,
  external int platform;
  @ffi.Int32()
  external int width;          //camera image width
  @ffi.Int32()
  external int height;         //camera image height
  @ffi.Int32()
  external int rotation;       //rotation degree of image, get from mobile sensor

}
//image of yuv420
class MichImagePlane extends ffi.Struct{
  external ffi.Pointer<ffi.Uint8> planeData;
  external ffi.Pointer<MichImagePlane> nextPlane;

  @ffi.Int32()
  external int bytesPerRow;

  @ffi.Int32()
  external int length;

}

//The image returned from opencv, can be used directly by flutter Image.memory
class MichImageMemory extends ffi.Struct{
  external ffi.Pointer<ffi.Uint8> rtImg;    //returned Image of UInt8List
  external ffi.Pointer<ffi.Uint32> rtSize;  //size of image
}

class MRect extends ffi.Struct{
  @ffi.Int32()
  external int x;

  @ffi.Int32()
  external int y;

  @ffi.Int32()
  external int width;

  @ffi.Int32()
  external int height;
}

//to accept the analyzed result from native
class MrzRoiOCR extends ffi.Struct{
  external ffi.Pointer<MichImageMemory> imgMrzRoi;
  external ffi.Pointer<Utf8> passportText;
}


//
class MrzResult{
  Uint8List imgBytes;
  String ocrText;
  late Duration processDur;
  MrzResult(this.imgBytes,this.ocrText);
}
class MichFrameForProcess {
  CameraImage image;
  int rotation;

  MichFrameForProcess(this.image, this.rotation);
}
