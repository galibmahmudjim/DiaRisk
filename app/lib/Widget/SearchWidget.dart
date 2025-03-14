// create a widget

import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  final double boxheight;
  final double boxwidth;
  final Function(bool?) callback;
  final Function(String?) callbackText;

  const SearchWidget(
      {required this.boxheight,
      required this.boxwidth,
      required this.callback,
      required this.callbackText});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController textController = TextEditingController();
  String error = "";
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String nameError = "";
  double height = 0;
  double width = 0;
  double navHeight = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    height = widget.boxheight;
    width = widget.boxwidth;
    Future.delayed(Duration(milliseconds: 10), () {
      setState(() {
        navHeight = 60;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();
    return AnimatedContainer(
      clipBehavior: Clip.hardEdge,
      width: width,
      height: navHeight,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
      // Set the width of the container
      // Add some padding
      decoration: BoxDecoration(
        color: Color(0x1A8D8686),
        border: Border.all(
          color: Colors.transparent, // Add a border around the container
          width: 2.0,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              widget.callback(true);
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Opacity(
              opacity: 0.5,
              child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF464647),
                ),
              ),
            ),
          ),
          SizedBox(
            width: width * 0.05,
          ),
          Container(
            width: width * 0.6,
            child: TextField(
              onChanged: (value) {
                widget.callbackText(value);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                alignLabelWithHint: true,
                hintText: 'Enter text here',
                hintStyle: TextStyle(
                  color: Color(0x91737379),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
