import 'package:pm_opencv_plugin/globals/err_msg.dart' as err;

class IProcessResult<T>{
   late final int errCode;
   late final String? msg;
   late final T? result;
   IProcessResult(this.errCode,this.msg,this.result);

   IProcessResult.finished({
      required int ec,
      String? eMsg,
      T? pResult}){
      errCode = ec;
      eMsg == null?msg = err.errMsg[errCode]:msg = eMsg;
      result = pResult;
   }
   IProcessResult.failed({
      required int ec,
      String? eMsg,
   }){
      print("failed IProcessResult");
      errCode = ec;
      eMsg == null?msg = err.errMsg[errCode]:msg = eMsg;
      result = null;
   }
}