import 'package:droptel/Constants/radioButtonDetails.dart';
import 'package:flutter/material.dart';

class RadioButtonCustom extends StatefulWidget {
  final buttonDetails buttons;

  const RadioButtonCustom({required this.buttons});

  @override
  State<RadioButtonCustom> createState() =>
      _RadioButtonCustomState(buttons: buttons);
}

/// This is the private State class that goes with RadioButtonCustom.
class _RadioButtonCustomState extends State<RadioButtonCustom> {
  buttonDetails buttons;

  _RadioButtonCustomState({required this.buttons});

  int? value;

  Widget CustomRadioButton(String text, int index, bool isSelected) {
    return OutlinedButton(
        onPressed: () {
          setState(() {
            value = index;
          });
        },
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.white,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.white,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return CustomRadioButton(buttons.text, buttons.index, buttons.isSelected);
  }
}
