import 'package:pm_opencv_plugin/globals/err_msg.dart' as err;

class PmException implements Exception{
  int errCode;
  PmException(this.errCode);

  String get msg => err.errMsg[errCode]!;

  @override
  String toString() {
    // TODO: implement toString
    return "ArgumentException: $errCode: ${err.errMsg[errCode]}";
  }
}
class PmExceptionEx implements Exception{

  int errCode;
  String? exMsg;
  PmExceptionEx(this.errCode,this.exMsg);

  String get msg => "${err.errMsg[errCode]!}.${exMsg??"Unknown Error"}";

  @override
  String toString() =>
    "ArgumentException: $errCode: ${err.errMsg[errCode]}. $exMsg";
}
