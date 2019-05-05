import 'package:flutter/material.dart';

class UserTag extends StatelessWidget {
  final String user;

  UserTag({this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding:EdgeInsets.all(10.0),
          child: Text('Added by:'+user),
        ),
      ],
    );
  }
}
