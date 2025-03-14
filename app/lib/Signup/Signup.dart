import 'package:droptel/Obj/User.dart';
import 'package:droptel/homeLogin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:objectid/objectid.dart';

import '../Widget/snackbar.dart';

class SignupWidget extends StatefulWidget {
  final double boxheight;
  final double boxwidth;
  final User user;
  final Function(bool?) callback;

  const SignupWidget(
      {required this.boxheight,
      required this.boxwidth,
      required this.user,
      required this.callback});

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  TextFormField? textFormField = TextFormField();
  String error = "";
  bool passwordVisible = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String emailError = "";
  String passwordError = "";
  String confirmPasswordError = "";
  String dateOfBirthError = "";
  String nameError = "";
  DateTime date = DateTime.now();

  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  User user = User();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
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
                controller: emailController,
                cursorColor: Colors.black,
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
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    fontFamily: GoogleFonts.prompt().fontFamily,
                    color: Color(0xFFA8A8B3),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return "Enter valid email";
                  } else if (value!.isEmpty) {
                    setState(() {
                      emailError = "Email is required";
                    });
                    return "* Required";
                  } else if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$",
                          caseSensitive: false, multiLine: false)
                      .hasMatch(value)) {
                    setState(() {
                      emailError = "Enter valid email";
                    });
                    return "Enter valid email";
                  } else {
                    setState(() {
                      emailError = "";
                    });
                    return null;
                  }
                },
                onSaved: (val) {},
              ),
            ), //email
            SizedBox(
              height: widget.boxwidth / 200,
            ),
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
                controller: nameController,
                cursorColor: Colors.black,
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
                  if (value == null) {
                    return "Enter Name";
                  } else if (value!.isEmpty) {
                    setState(() {
                      nameError = "Name is required";
                    });
                    return "* Required";
                  } else {
                    setState(() {
                      nameError = "";
                    });
                    return null;
                  }
                },
                onSaved: (val) {},
              ),
            ), //name
            SizedBox(
              height: widget.boxwidth / 200,
            ),
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
                controller: dateOfBirthController,
                readOnly: true,
                cursorColor: Colors.black,
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFFA8A8B3),
                    ),
                    onPressed: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            date = value;
                            dateOfBirthController.text =
                                "${date.day}-${date.month}-${date.year}";
                          });
                        }
                      });
                    },
                  ),
                  hintText: 'Enter your date of birth',
                  hintStyle: TextStyle(
                    fontFamily: GoogleFonts.prompt().fontFamily,
                    color: Color(0xFFA8A8B3),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                validator: (value) {
                  if (value == null) {
                    return "Enter Date of Birth";
                  } else if (value!.isEmpty) {
                    setState(() {
                      dateOfBirthError = "Date of Birth is required";
                    });
                    return "* Required";
                  } else {
                    setState(() {
                      dateOfBirthError = "";
                    });
                    return null;
                  }
                },
                onSaved: (val) {},
              ),
            ), //date of birth

            SizedBox(
              height: widget.boxwidth / 200,
            ),

            Container(
                alignment: Alignment.center,
                height: widget.boxheight / 15,
                width: widget.boxwidth * 2 / 2.5,
                decoration: BoxDecoration(
                  color: Color(0x41A8A8B3),
                ),
                child: TextFormField(
                  controller: passwordController,
                  cursorColor: Colors.black,
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
                  obscureText: !passwordVisible,
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                        height: 0, color: Colors.transparent, fontSize: 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter secure password',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.prompt().fontFamily,
                      color: Color(0xFFA8A8B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    suffixIcon: IconButton(
                      icon: !passwordVisible
                          ? Icon(
                              Icons.visibility_off,
                              color: Color(0xFFA8A8B3),
                            )
                          : Icon(
                              Icons.visibility,
                              color: Color(0xFFA8A8B3),
                            ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Enter valid password";
                    } else if (value!.isEmpty) {
                      setState(() {
                        passwordError = "Password is required";
                      });
                      return "* Required";
                    } else if (value.length < 6) {
                      setState(() {
                        passwordError =
                            "Password should be atleast 6 characters";
                      });
                      return "Password should be atleast 6 characters";
                    } else if (value.length > 15) {
                      setState(() {
                        passwordError =
                            "Password should not be greater than 15 characters";
                      });
                      return "Password should not be greater than 15 characters";
                    } else
                      return null;
                  },
                  onSaved: (val) {},
                )), //password
            SizedBox(
              height: widget.boxwidth / 200,
            ),

            Container(
                alignment: Alignment.center,
                height: widget.boxheight / 15,
                width: widget.boxwidth * 2 / 2.5,
                decoration: BoxDecoration(
                  color: Color(0x41A8A8B3),
                ),
                child: TextFormField(
                  controller: confirmPasswordController,
                  cursorColor: Colors.black,
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
                  obscureText: !passwordVisible,
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    errorStyle: TextStyle(
                        height: 0, color: Colors.transparent, fontSize: 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Confirm password',
                    hintStyle: TextStyle(
                      fontFamily: GoogleFonts.prompt().fontFamily,
                      color: Color(0xFFA8A8B3),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Enter valid password";
                    } else if (value!.isEmpty) {
                      setState(() {
                        confirmPasswordError = "Password is required";
                      });
                      return "* Required";
                    } else if (value.length < 6) {
                      setState(() {
                        confirmPasswordError =
                            "Password should be atleast 6 characters";
                      });
                      return "Password should be atleast 6 characters";
                    } else if (value.length > 15) {
                      setState(() {
                        confirmPasswordError =
                            "Password should not be greater than 15 characters";
                      });
                      return "Password should not be greater than 15 characters";
                    } else
                      return null;
                  },
                  onSaved: (val) {},
                )), //password confirm

            SizedBox(
              height: widget.boxwidth / 200,
            ),
            //submit button
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
                  if (formkey.currentState!.validate() &&
                      passwordController.text.toString() ==
                          confirmPasswordController.text.toString()) {
                    setState(() {
                      emailError = "";
                      passwordError = "";
                      error = "";
                    });
                    final id = ObjectId().hexString;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePageLogin()),
                    );
                    widget.callback(false);
                  } else {
                    if (emailError.isNotEmpty) {
                      setState(() {
                        passwordError = "";
                        error = emailError;
                      });
                    } else if (passwordError.isNotEmpty) {
                      setState(() {
                        emailError = "";
                        error = passwordError;
                      });
                    } else if (passwordController.text.toString() !=
                        confirmPasswordController.text.toString()) {
                      setState(() {
                        error = "Password and Confirm Password should be same";
                      });
                    }
                  }
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontFamily: GoogleFonts.prompt().fontFamily,
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ), //submit button
            SizedBox(
              height: widget.boxwidth / 1000,
            ),
            Container(
              height: widget.boxheight / 20,
              width: widget.boxwidth / 1.5,
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
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ), //error show
          ]),
        ),
      ],
    );
  }
}
