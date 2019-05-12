import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

import '../widgets/ui_elements/title_default.dart';

class ProductPage extends StatelessWidget {
  final int productIndex;

  ProductPage({this.productIndex});

  Widget _buildAddressPriceRow(String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Union Square, San Francisco',
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey)),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text('|', style: TextStyle(color: Colors.grey))),
        Text('\$' + price,
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey))
      ],
    );
  }

  // _showWarningDialog(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Are you sure?'),
  //           content: Text('This action cannot be undone. '),
  //           actions: <Widget>[
  //             FlatButton(
  //                 child: Text('CANCEL'),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 }),
  //             FlatButton(
  //               child: Text('CONTINUE'),
  //               onPressed: () {
  //                 //close dialog
  //                 Navigator.pop(context);
  //                 //delete product and go back to products page.
  //                 Navigator.pop(context, true);
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Back button pressed.');
        Navigator.pop(context, false);
        //true means allowed to leave
        //since it is nevigated manually above, this needs to be false to ensure back
        //is not triggered twice causing the app to crash.
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return Scaffold(
          appBar: AppBar(
            title: Text(model.allProducts[productIndex].title),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.network(model.allProducts[productIndex].image),
              Container(
                padding: EdgeInsets.all(10.0),
                child: TitleDefault(title: model.allProducts[productIndex].title),
              ),
              _buildAddressPriceRow(model.allProducts[productIndex].price.toString()),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: Text(
                  model.allProducts[productIndex].description,
                  textAlign: TextAlign.center,
                ),
              ),
              // Container(
              //     padding: EdgeInsets.all(10.0),
              //     child: RaisedButton(
              //       color: Theme.of(context).accentColor,
              //       textColor: Colors.white,
              //       child: Text('DELETE'),
              //       onPressed: () {
              //         print('Delete pressed. ');
              //         _showWarningDialog(context);
              //       },
              //     ))
            ],
          ),
        );
      }),
    );
  }
}
