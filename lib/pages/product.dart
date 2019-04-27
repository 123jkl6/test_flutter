import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Single Product'),
        ),
        body: Column(
          children: <Widget>[
            Text('Product Details'),
            RaisedButton(
              child:Text('BACK'),
              onPressed: (){
                Navigator.pop(context);
              },
              )
            ],
          ),
      );;
  }
}