import 'package:flutter/material.dart';

import '../product_manager.dart';
import './manage_products.dart';

class ProductsPage extends StatelessWidget{
  final List<Map<String,dynamic>> products;

  ProductsPage({this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //depending on the os, this can be on the left or right
        drawer : Drawer(
          child: Column(
            children: <Widget>[
              AppBar(
                //Assume what the leading icon should be
                automaticallyImplyLeading:false,
                title:Text('Choose'),
              ),
              ListTile(
                title:Text('Manage Products'),
                onTap:(){
                  Navigator.pushReplacementNamed(
                    context, 
                    '/admin'
                  );
                },
              ),
              ListTile(
                title:Text('Auth'),
                onTap:(){
                  Navigator.pushReplacementNamed(
                    context, 
                    '/auth'
                  );
                },
              ),
            ]
          ),
        ),
        appBar: AppBar(
          title: Text('Haha'),
        ),
        body: ProductManager(
          products: products,
        ),
      );
  }

}