//write a page for login
import 'package:droptel/Constants/Logger.dart';
import 'package:droptel/Login/loginPage.dart';
import 'package:droptel/Signup/Signup.dart';
import 'package:droptel/Widget/guestEntry.dart';
import 'package:droptel/Widget/loading.dart';
import 'package:droptel/Widget/snackbar.dart';
import 'package:droptel/Pages/homepage.dart';
import 'package:droptel/Model/sharedPref.dart';
import 'package:droptel/Constants/Constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../Constants/radioButtonDetails.dart';
import 'Obj/User.dart' as app_user;

class HomePageLogin extends StatefulWidget {
  const HomePageLogin({super.key});

  @override
  State<HomePageLogin> createState() => _HomePageLoginState();
}

class _HomePageLoginState extends State<HomePageLogin> {
  final loginForm = 1;
  final signupForm = 2;
  int form = 1;
  bool guestClicked = false;
  bool loginClicked = true;
  bool loadingHome = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    try {
      setState(() {
        loadingHome = true;
      });

      // Check for access token
      final token = await sharedPref.getToken();
      logger.d('Token: $token');

      if (token != null) {
        // If token exists, try to get user info from server
        final response = await http.get(
          Uri.parse('${Constants.baseUrl}/api/v1/auth/me'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body)['data']['user'];

          // Create user object from server data
          app_user.User appUser = app_user.User(
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            imageURL: userData['picture'] ?? '',
          );

          // Navigate to home page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: appUser),
            ),
          );
        } else {
          // If token is invalid, clear it
          await sharedPref.clearToken();
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
      await sharedPref.clearToken();
    } finally {
      setState(() {
        loadingHome = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        loadingHome = true;
      });

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          loadingHome = false;
        });
        return;
      }

      // Send user data to your server
      logger.d('Google User: ${googleUser}');
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/v1/auth/google-auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': googleUser.email,
          'name': googleUser.displayName,
          'photo_url': googleUser.photoUrl
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to authenticate with server');
      }

      final serverResponse = jsonDecode(response.body);

      // Create a User object with the server response data
      app_user.User appUser = app_user.User(
        name: serverResponse['data']['user']['name'] ?? '',
        email: serverResponse['data']['user']['email'] ?? '',
        imageURL: serverResponse['data']['user']['photo_url'] ?? '',
      );

      // Save user data to shared preferences
      await sharedPref.setToken(serverResponse['data']['access_token']);

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(user: appUser),
        ),
      );
    } catch (e) {
      print('Error signing in with Google: $e');
      snackBar(context, "Failed to sign in with Google", Colors.red);
    } finally {
      setState(() {
        loadingHome = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final theme = Theme.of(context);

    Color colorNotclicked = Color(0xC9C9CC);
    Color colorClicked = Color(0x6CC3C3C3);
    bool googleClicked = false;
    bool facebookClicked = false;

    double boxheight = MediaQuery.of(context).size.height;
    double boxwidth = MediaQuery.of(context).size.width;
    app_user.User user = app_user.User();

    List<buttonDetails> buttons = [
      buttonDetails(text: 'Login', index: loginForm, isSelected: false),
      buttonDetails(text: 'Signup', index: signupForm, isSelected: false)
    ];
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: boxheight / 20),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            width: boxwidth,
                            child: Text('DIARISK',
                                style: GoogleFonts.prompt(
                                  textStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height /
                                              20,
                                      fontWeight: FontWeight.w300,
                                      color: theme.colorScheme.onBackground,
                                      letterSpacing: 15),
                                ))),
                        SizedBox(
                          height: boxheight / 20,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text("Express login via Google and Facebook",
                              style: GoogleFonts.saira(
                                textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.7),
                                    letterSpacing: .5),
                              )),
                        ),
                        SizedBox(
                          height: boxheight / 50,
                        ),
                        Container(
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                                onTap: _handleGoogleSignIn,
                                child: Container(
                                    height: boxheight / 15,
                                    width: boxwidth / 2.5,
                                    decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Google',
                                          style: GoogleFonts.prompt(
                                            textStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: theme
                                                    .colorScheme.onBackground,
                                                letterSpacing: .5),
                                          ),
                                        ),
                                        SizedBox(
                                          width: boxwidth / 40,
                                        ),
                                        Container(
                                          height: boxheight / 60,
                                          child: Image.asset(
                                            'assets/signin-google.png',
                                            height: boxheight / 20,
                                            width: boxwidth / 20,
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                              SizedBox(
                                width: boxwidth / 50,
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    facebookClicked = true;
                                  });
                                },
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                child: Container(
                                    height: boxheight / 15,
                                    width: boxwidth / 2.5,
                                    decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Facebook',
                                          style: GoogleFonts.prompt(
                                            textStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: theme
                                                    .colorScheme.onBackground,
                                                letterSpacing: .5),
                                          ),
                                        ),
                                        SizedBox(
                                          width: boxwidth / 80,
                                        ),
                                        Container(
                                          height: boxheight / 60,
                                          child: Image.asset(
                                            'assets/signin-facebook.png',
                                            height: boxheight / 20,
                                            width: boxwidth / 20,
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: boxheight / 30,
                        ),
                        SizedBox(
                          height: boxheight / 30,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: boxheight / 290,
                          width: boxwidth * 2 / 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color(0x41A8A8B3),
                          ),
                        ),
                        SizedBox(
                          height: boxheight / 30,
                        ),
                        Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    alignment: Alignment.topCenter,
                                    height: boxheight / 20,
                                    width: boxwidth / 1.49,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: boxwidth / 40,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              loginClicked = true;
                                              guestClicked = false;
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: boxheight / 20,
                                            width: boxwidth / 6,
                                            decoration: BoxDecoration(
                                                color: guestClicked
                                                    ? colorNotclicked
                                                    : loginClicked
                                                        ? colorClicked
                                                        : colorNotclicked,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10))),
                                            child: Text(
                                              'Login',
                                              style: GoogleFonts.prompt(
                                                textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF464647),
                                                    letterSpacing: .5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: boxwidth / 30,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              loginClicked = false;
                                              guestClicked = false;
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: boxheight / 20,
                                            width: boxwidth / 6,
                                            decoration: BoxDecoration(
                                                color: guestClicked
                                                    ? colorNotclicked
                                                    : !loginClicked
                                                        ? colorClicked
                                                        : colorNotclicked,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10))),
                                            child: Text(
                                              'Signup',
                                              style: GoogleFonts.prompt(
                                                textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF464647),
                                                    letterSpacing: .5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: boxwidth / 20,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              guestClicked = true;
                                              loginClicked = false;
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: boxheight / 20,
                                            width: boxwidth / 6,
                                            decoration: BoxDecoration(
                                                color: guestClicked
                                                    ? colorClicked
                                                    : colorNotclicked,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    topLeft:
                                                        Radius.circular(10))),
                                            child: Text(
                                              'Guest',
                                              style: GoogleFonts.prompt(
                                                textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF464647),
                                                    letterSpacing: .5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: boxwidth / 30,
                                        ),
                                      ],
                                    )),
                                SizedBox(
                                  height: boxheight / 100000,
                                ),
                                guestClicked
                                    ? GuestWidget(
                                        user: user,
                                        boxheight: boxheight,
                                        boxwidth: boxwidth,
                                        callback: (bool? load) {
                                          setState(() {
                                            loadingHome = load!;
                                          });
                                        },
                                      )
                                    : loginClicked
                                        ? LoginWidget(
                                            user: user,
                                            boxheight: boxheight,
                                            boxwidth: boxwidth,
                                            callback: (bool? loading) {
                                              setState(() {
                                                loadingHome = loading!;
                                                initState() {}
                                              });
                                            },
                                          )
                                        : SignupWidget(
                                            user: user,
                                            boxheight: boxheight,
                                            boxwidth: boxwidth,
                                            callback: (bool? loading) {
                                              setState(() {
                                                loadingHome = loading!;
                                                initState() {}
                                              });
                                            },
                                          ),
                                SizedBox(
                                  height: boxheight / 60,
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loadingHome)
            Opacity(
                opacity: 0.6,
                child: loading(
                    heightBox: MediaQuery.of(context).size.height,
                    widthBox: MediaQuery.of(context).size.width)),
        ],
      ),
    );
  }
}
