import 'package:flutter/material.dart';

class CreateProductPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title:Text('Create Product')
      ),
      body: Column(
        children: <Widget>[
          Text('Creating a product.')
        ]
      ),
    );
  }
}