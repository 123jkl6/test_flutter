import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

import './product_edit.dart';

class ProductListPage extends StatefulWidget {
  final MainModel model;

  ProductListPage({this.model});

  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  initState() {
    widget.model.fetchProducts();
    super.initState();
  }

  Widget _builEditButton(BuildContext context, MainModel model, int index) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectProduct(index);
        print('Edit pressed. ');
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
          return ProductEditPage();
        })).then((_) => model
            .selectProduct(null)); //unselect product when pressing back button
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(model.allProducts[index].title),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                print('Swiped end to start.');
                //acually delete the product.
                model.selectProduct(index);
                model.deleteProduct();
              } else if (direction == DismissDirection.startToEnd) {
                print('Swiped start to end.');
              } else {
                print('Other swiping.');
              }
            },
            background: Container(
              color: Theme.of(context).accentColor,
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allProducts[index].image),
                    ),
                    title: Text(model.allProducts[index].title),
                    subtitle:
                        Text('\$${model.allProducts[index].price.toString()}'),
                    trailing: _builEditButton(context, model, index)),
                Divider(
                  color: Colors.black,
                )
              ],
            ),
          );
        },
        itemCount: model.allProducts.length,
      );
    });
  }
}
