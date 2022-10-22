class IProcessResult<T>{
   //0: success,
   // -1: native error 1, -2: native error 2, -3: native error 3
   // -4: scan
   late int errCode;
   late String msg;
   late T result;
}