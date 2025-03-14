// create a widget

import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final double boxheight;
  final double boxwidth;
  final Function(bool?) callback;

  const SearchBarWidget(
      {required this.boxheight,
      required this.boxwidth,
      required this.callback});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  TextEditingController textController = TextEditingController();
  String error = "";
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String nameError = "";
  double height = 0;
  double width = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    height = widget.boxheight;
    width = widget.boxwidth;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      //background color
      height: height / 15,
      width: width,
      decoration: BoxDecoration(
        color: Color(0x1A8D8686),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(100),
            bottomRight: Radius.circular(100),
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              debugPrint("search");
              widget.callback(true);
            },
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              child: Row(children: [
                SizedBox(
                  width: width * 0.05,
                ),
                Opacity(
                  opacity: 0.5,
                  child: Icon(
                    Icons.search,
                  ),
                ),
                SizedBox(
                  width: width * 0.05,
                ),
                Opacity(
                  opacity: 0.5,
                  child: Text(
                    "Search",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ]),
            ),
          ),
          Row(children: [
            Container(
              padding: EdgeInsets.only(
                  top: height * 0.01,
                  bottom: height * 0.01,
                  left: width * 0.01,
                  right: width * 0.01),
              child: Opacity(
                opacity: 0.9,
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/cat.jpeg'),
                ),
              ),
            ),
            SizedBox(
              width: width * 0.02,
            ),
          ]),
        ],
      ),
    );
  }
}
