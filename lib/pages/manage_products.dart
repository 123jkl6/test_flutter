import 'package:flutter/material.dart';

import './product_edit.dart';
import './product_list.dart';

class ManageProducts extends StatelessWidget {
  final Function addProduct;
  final Function deleteProduct;
  final Function updateProduct;
  final List<Map<String,dynamic>> products;

  ManageProducts({this.addProduct, this.updateProduct,this.deleteProduct,this.products});

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            //Assume what the leading icon should be
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Products Page'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: _buildSideDrawer(context),
        appBar: AppBar(
          title: Text('Manage products'),
          bottom: TabBar(tabs: <Widget>[
            Tab(icon: Icon(Icons.create), text: 'Create Product'),
            Tab(icon: Icon(Icons.list), text: 'My Products')
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            ProductEditPage(
              addProduct: addProduct,
            ),
            ProductListPage(updateProduct:updateProduct,deleteProduct:deleteProduct,products: products,)
          ],
        ),
      ),
    );
  }
}
