import 'package:flutter/material.dart';

import './products.dart';
import './create_product.dart';
import './product_list.dart';

class ManageProducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                AppBar(
                  //Assume what the leading icon should be
                  automaticallyImplyLeading: false,
                  title: Text('Choose'),
                ),
                ListTile(
                  title: Text('Products Page'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context,'/' );
                  },
                )
              ],
            ),
          ),
          appBar: AppBar(
            title: Text('Manage products'),
            bottom:TabBar(
              tabs : <Widget>[
                Tab(
                  icon:Icon(Icons.create), 
                  text:'Create Product'
                  ),
                Tab(
                  icon:Icon(Icons.list), 
                  text:'My Products'
                  )
              ]
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              CreateProductPage(),
              ProductListPage()
            ],
          ),
        ),
    );
  }
}
