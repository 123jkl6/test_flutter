import 'package:flutter/material.dart';

class TitleDefault extends StatelessWidget {
  final String title;

  TitleDefault({this.title});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = 15.0;
    if (screenWidth>700){
      fontSize=20.0;
    }
    return Text(title,
        softWrap: true,
        textAlign: TextAlign.center,
        style: TextStyle(
          
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ));
  }
}
