
import 'package:ffi/ffi.dart';
import 'dart:ffi' as ffi;
import 'package:pm_opencv_plugin/controller/proc_ffi.dart';

class FmProcessArgument {
  String? pMrzTFD; //directory of passport mrz trained file directory
  String? pMrzTF; //file of passport mrz trained data}
  //String? mrzQtFD; //directory of passport mrz trained data for quick process
  //String? mrzQtF;  //file of passport mrz trained data for quick process
  FmProcessArgument({this.pMrzTFD, this.pMrzTF});
}

class Fms2nProcessArgument extends ffi.Struct{
  external ffi.Pointer<Utf8> pMrzTFD; //directory of passport mrz trained file directory
  external ffi.Pointer<Utf8> pMrzTF; //directory of passport mrz trained file
  /*
  external ffi.Pointer<Utf8> mrzQtFD; //fast trained data
  external ffi.Pointer<Utf8> mrzQtF;  // fast trained data
  */
}


extension Ep2nProcessArgument on ffi.Pointer<Fms2nProcessArgument> {
  void release() {
    var pD = ref.pMrzTFD;
    var pF = ref.pMrzTF;
    //var pQD = ref.mrzQtFD;
    //var pQF = ref.mrzQtF;
    if(pD != ffi.nullptr)malloc.free(pD);
    if(pF != ffi.nullptr)malloc.free(pF);
    /*
    print("free 1-2");
    print("null ptr: ${pQD == ffi.nullptr}");
    print("null ptr: ${pQF == ffi.nullptr}");
    if(pQD != ffi.nullptr)malloc.free(pQD);
    if(pQF != ffi.nullptr)malloc.free(pQF);
     */
    print("free 1-3");
    if(this != ffi.nullptr)malloc.free(this);
  }
}
extension EfmProcessArgument on FmProcessArgument {
  ffi.Pointer<Fms2nProcessArgument> toArgumentPointer() {
    ffi.Pointer<Fms2nProcessArgument> argumentPointer = ffiCreateArgumentP();
    final argumentP = argumentPointer.ref;
    //best trained data
    argumentP.pMrzTFD = pMrzTFD!.toNativeUtf8();
    argumentP.pMrzTF = pMrzTF!.toNativeUtf8();

    //fast trained data
    /*
    mrzQtFD == null
        ? argumentP.mrzQtFD = ffi.nullptr
        : argumentP.mrzQtFD = mrzQtFD!.toNativeUtf8();

    mrzQtF == null
        ? argumentP.mrzQtF = ffi.nullptr
        : argumentP.mrzQtF = mrzQtF!.toNativeUtf8();
    */
    return argumentPointer;
  }
}