import 'package:flutter/material.dart';

import '../widgets/products/products.dart';

class ProductsPage extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  ProductsPage({this.products});

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(children: <Widget>[
        AppBar(
          //Assume what the leading icon should be
          automaticallyImplyLeading: false,
          title: Text('Choose'),
        ),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Products'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/admin');
          },
        ),
        ListTile(
          title: Text('Auth'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/auth');
          },
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //depending on the os, this can be on the left or right
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('Haha'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              print('Favorite filter pressed.');
            },
          ),
        ],
      ),
      body: Products(
        products: products,
      ),
    );
  }
}
