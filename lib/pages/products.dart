import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

import '../widgets/products/products.dart';
import '../widgets/ui_elements/logout_list.dart';

class ProductsPage extends StatefulWidget {
  final MainModel model;

  ProductsPage(this.model);
  @override
  State<ProductsPage> createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  initState() {
    widget.model.fetchProducts();
    super.initState();
  }

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
        Divider(),
          LogoutListTile(),
        
      ]),
    );
  }

  Widget _buildProductsList() {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      Widget content = Center(child: Text('No products found. '));
      if (model.displayedProducts.length > 0 && !model.isLoading) {
        content = Products();
      } else if (model.isLoading) {
        content = Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(onRefresh: () {
        return model.fetchProducts();
      }, child: content);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //depending on the os, this can be on the left or right
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('Haha'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
              builder: (BuildContext context, Widget child, MainModel model) {
            return IconButton(
              icon: Icon(model.showFavoritesMode
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () {
                print('Favorite filter pressed.');
                model.toggleDisplayFavorites();
              },
            );
          }),
        ],
      ),
      body: _buildProductsList(),
    );
  }
}
