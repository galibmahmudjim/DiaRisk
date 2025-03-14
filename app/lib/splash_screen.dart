import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:droptel/Model/sharedPref.dart';
import 'package:droptel/Pages/homepage.dart';
import 'package:droptel/homeLogin.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

class splash_screen extends StatefulWidget {
  const splash_screen({super.key});

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {

  Future<Widget> checkIn() async {
    final String? id = await sharedPref.getID();
    final String? name = await sharedPref.getName();
    if (id != null && name != null) {
      return HomePage(id: id!, name: name!);
    } else {
      return HomePageLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenFunction(
      splash: Image.asset('assets/icon.png'),
      splashIconSize: MediaQuery.of(context).size.height / 3,
      backgroundColor: Color(0xFFFFFFFF),
      pageTransitionType: PageTransitionType.rightToLeft,
      splashTransition: SplashTransition.slideTransition,
      screenFunction: () async {
        return checkIn();
      },
    );
  }
}
