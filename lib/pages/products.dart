import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

import '../widgets/products/products.dart';

class ProductsPage extends StatelessWidget {
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
          ScopedModelDescendant<MainModel>(builder:
              (BuildContext context, Widget child, MainModel model) {
            return IconButton(
              icon: Icon(model.showFavoritesMode ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                print('Favorite filter pressed.');
                model.toggleDisplayFavorites();
              },
            );
          }),
        ],
      ),
      body: Products(),
    );
  }
}
