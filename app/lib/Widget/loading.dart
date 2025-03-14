import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class loading extends StatefulWidget {
  final double heightBox;
  final double widthBox;

  const loading({required this.heightBox, required this.widthBox});

  @override
  State<loading> createState() => _loadingState();
}

class _loadingState extends State<loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: widget.heightBox,
      width: widget.widthBox,
      child: Center(
          child: SpinKitPulse(
        size: widget.widthBox * 0.5,
        itemBuilder: (BuildContext context, int index) {
          return Opacity(
            opacity: 0.5,
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/icon.png'),
              backgroundColor: Colors.transparent,
            ),
          );
        },
      )),
    );
  }
}
