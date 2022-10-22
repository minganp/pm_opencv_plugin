extension MulitCharacter on String{
  String multiChar(int number){
    String reStr="";
    while(number>=0){
      reStr = reStr + this;
      number = number -1;
    }
    return reStr;
  }
}