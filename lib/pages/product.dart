import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';

import '../models/product.dart';

import '../widgets/ui_elements/title_default.dart';

class ProductPage extends StatelessWidget {
  final Product product;

  ProductPage({this.product});

  void _showMap() {
    final List<Marker> markers = <Marker>[
      Marker('position', 'Position', product.location.latitude,
          product.location.longitude),
    ];
    final cameraPosition = CameraPosition(
        Location(product.location.latitude, product.location.longitude), 14.0);
    final mapView = MapView();
    mapView.show(MapOptions(
        initialCameraPosition: cameraPosition,
        mapViewType: MapViewType.normal,
        title: 'Product Location'),
        toolbarActions:[ToolbarAction('Close',1),],);
        mapView.onToolbarAction.listen((int id){
          if (id==1){
            mapView.dismiss();
          }
        });
        mapView.onMapReady.listen((_){
          mapView.setMarkers(markers);
        });
  }

  Widget _buildAddressPriceRow(String address, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: _showMap,
          child: Text(address,
              style: TextStyle(fontFamily: 'Oswald', color: Colors.grey)),
        ),
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FadeInImage(
                image: NetworkImage(product.image),
                height: 300.0,
                fit: BoxFit.cover,
                fadeInDuration: Duration(milliseconds: 700),
                placeholder: AssetImage('assets/food.jpg')),
            Container(
              padding: EdgeInsets.all(10.0),
              child: TitleDefault(title: product.title),
            ),
            _buildAddressPriceRow(
                product.location.address, product.price.toString()),
            Container(
              margin: EdgeInsets.only(top: 10.0),
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              child: Text(
                product.description,
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
      ),
    );
  }
}
