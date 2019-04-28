import 'package:flutter/material.dart';

class ProductListPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title:Text('Products')
      ),
      body: Column(
        children: <Widget>[
          Text('Listing products.')
        ]
      ),
    );
  }
}