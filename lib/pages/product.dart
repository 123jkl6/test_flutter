import 'dart:async';
import 'package:flutter/material.dart';

class ProductPage extends StatelessWidget {
  String title;
  String imageUrl;

  ProductPage({this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:(){
        print('Back button pressed.'); 
        Navigator.pop(context,false); 
        //true means allowed to leave
        //since it is nevigated manually above, this needs to be false to ensure back 
        //is not triggered twice causing the app to crash. 
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(imageUrl),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text('Product Details'),
            ),
            Container(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text('DELETE'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ))
          ],
        ),
      ),
    );
  }
}
