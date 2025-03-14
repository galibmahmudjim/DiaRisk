import 'package:flutter/material.dart';
import 'package:droptel/Theme/app_theme.dart';
import 'package:droptel/homeLogin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiaRisk',
      theme: AppTheme.lightTheme,
      home: HomePageLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}
