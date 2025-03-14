import 'package:flutter/material.dart';

snackBar(BuildContext context, String msg, Color color) {
  var snackdemo = SnackBar(
    dismissDirection: DismissDirection.endToStart,
    content: Text(msg),
    backgroundColor: color,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(5),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackdemo);
}
