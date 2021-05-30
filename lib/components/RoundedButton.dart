import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Color bgColor;
  final String btnText;
  final  Function onBtnPress;

  RoundedButton({ this.bgColor, this.btnText, this.onBtnPress});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: bgColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed:onBtnPress ,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            btnText,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}