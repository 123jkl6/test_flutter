import 'package:flutter/material.dart';

import '../scoped_models/main.dart';

import '../widgets/ui_elements/logout_list.dart';

import './product_edit.dart';
import './product_list.dart';

class ManageProducts extends StatelessWidget {
  final MainModel model;

  ManageProducts({this.model});

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
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
          ),
          Divider(),
          LogoutListTile(),
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
          //iOS typcally has no drop shadows
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          bottom: TabBar(tabs: <Widget>[
            Tab(icon: Icon(Icons.create), text: 'Create Product'),
            Tab(icon: Icon(Icons.list), text: 'My Products')
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            ProductEditPage(),
            ProductListPage(model: model),
          ],
        ),
      ),
    );
  }
}
