import 'package:droptel/Model/Mongodb.dart';
import 'package:droptel/Model/sharedPref.dart';
import 'package:droptel/Obj/User.dart';
import 'package:droptel/Pages/homepage.dart';
import 'package:droptel/Widget/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:objectid/objectid.dart';

class GuestWidget extends StatefulWidget {
  final double boxheight;
  final double boxwidth;
  final User user;
  final Function(bool?) callback;

  const GuestWidget(
      {required this.boxheight,
      required this.boxwidth,
      required this.user,
      required this.callback});

  @override
  State<GuestWidget> createState() => _GuestWidgetState();
}

class _GuestWidgetState extends State<GuestWidget> {
  TextFormField? textFormField = TextFormField();
  TextEditingController nameController = TextEditingController();
  String error = "";
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String nameError = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: Column(children: [
        Container(
          alignment: Alignment.centerLeft,
          height: widget.boxheight / 15,
          width: widget.boxwidth * 2 / 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            color: Color(0x41A8A8B3),
          ),
          child: TextFormField(
            cursorColor: Colors.black,
            controller: nameController,
            style: TextStyle(
              fontSize: 16,
              fontFamily: GoogleFonts.prompt(
                letterSpacing: 1,
                color: Color(0xFF464647),
              ).fontFamily,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
              color: Color(0xFF464647),
            ),
            textAlignVertical: TextAlignVertical.bottom,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              errorStyle: TextStyle(height: 0, fontSize: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter your name',
              hintStyle: TextStyle(
                fontFamily: GoogleFonts.prompt().fontFamily,
                color: Color(0xFFA8A8B3),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                setState(() {
                  nameError = "Name is required";
                });
                return "* Required";
              } else {
                return null;
              }
            },
            onSaved: (val) {},
          ),
        ),
        SizedBox(
          height: widget.boxwidth / 200,
        ),
        Container(
          height: widget.boxheight / 15,
          width: widget.boxwidth * 2 / 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5)),
            color: Color(0xFF111112),
          ),
          child: TextButton(
            onPressed: () async {
              if (formkey.currentState!.validate()) {
                setState(() {
                  nameError = "";
                  error = "";
                });
                widget.callback(true);
                String id = ObjectId().hexString;

                User user = User(
                  id: id,
                  name: nameController.text,
                );
                await sharedPref.setID(id);
                await sharedPref.setName(nameController.text);
                Future<dynamic> newuser = Mongodb.NewUser(user);
                bool flag = true;
                newuser.timeout(Duration(seconds: 2), onTimeout: () {
                  widget.callback(false);
                  snackBar(context, "Please check your internet connection",
                      Colors.red);
                  setState(() {
                    flag = false;
                  });
                });
                newuser.then((value) {
                  if (value != null && flag == true) {
                    widget.callback(false);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(
                                  user: user,
                                )));
                  }
                });
              } else {
                if (nameError.isNotEmpty) {
                  setState(() {
                    error = nameError;
                  });
                }
              }
            },
            child: Text(
              'Next',
              style: TextStyle(
                fontFamily: GoogleFonts.prompt().fontFamily,
                color: Color(0xFFFFFFFF),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        SizedBox(
          height: widget.boxwidth / 1000,
        ),
        Container(
          height: widget.boxheight / 15,
          width: widget.boxwidth * 2 / 2.5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5)),
            color: Color(0x111112),
          ),
          child: Text(
            error.toString(),
            style: TextStyle(
              fontFamily: GoogleFonts.prompt().fontFamily,
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ]),
    );
  }
}
