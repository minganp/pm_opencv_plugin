import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pm_opencv_plugin_example/util/util.dart';

class ScanLine extends StatefulWidget{
  final double height;
  final double width;
  bool startOr = false;
  ScanLine(
      {Key? key,
        required this.width,
        required this.height,
        this.startOr = false,
      }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ScanLineState();
  }

class ScanLineState extends State<ScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(seconds: 5))
    ..repeat(reverse: true);
  late final Animation<AlignmentGeometry> _animation = Tween<AlignmentGeometry>(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter
  ).animate(
    CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear),
  );
  void startScan(){
    _animationController.forward();
  }
  void endScan(){
    _animationController.stop();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_animationController.forward();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.startOr?
      AlignTransition(
          alignment: _animation,
          child:const Divider(
            color: Colors.green,
            indent: 5,
            endIndent: 5,
            thickness: 5,),):Container();
  }
}

class AuxiliaryWords extends StatefulWidget{
  const AuxiliaryWords({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AuxiliaryWordsState();

}

class AuxiliaryWordsState extends State<AuxiliaryWords>
  with SingleTickerProviderStateMixin {
  String auxiliaryWords = ">".multiChar(44);
  late Animation<Color?> animation;
  late AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this,duration: const Duration(seconds: 5))..repeat();
    animation = ColorTween(begin: Colors.black12,end: Colors.black54).animate(controller);
    controller.forward();
  }
  void animateColor(){
    controller.forward();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        direction: Axis.vertical,
        children:
        auxiliaryWords.split("").map((string) =>
            Text(string, style: TextStyle(fontSize: 22,color: animation.value)))
            .toList(),
      ),
    );
  }

}


Widget scanStack(double height,double width){
        return Container(
          height: height,
          width:  width,
          padding: const EdgeInsets.only(
              left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 5.0),
          ),
          child: Stack(
              children: [
                const AuxiliaryWords(),
                ScanLine(width: width, height: height),
              ]
          ));
    }


