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
    widget.model.fetchProducts(onlyForUser: true, clearExisting: true);
    super.initState();
  }

  Widget _builEditButton(BuildContext context, MainModel model, int index) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectProduct(model.allProducts[index].id);
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
            confirmDismiss: (DismissDirection direction) async {
              bool deleteConfirm = false;
              if (direction == DismissDirection.endToStart) {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text(
                            "Are you sure you want to delete this product?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Confirm"),
                            onPressed: () {
                              print("confirm delete");
                              deleteConfirm = true;
                              Navigator.pop(context, true);
                            },
                          ),
                          FlatButton(
                            color: Colors.grey,
                            child: Text("Cancel"),
                            onPressed: () {
                              print("cancel delete");
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              } else {
                return true;
              }

              print(deleteConfirm);
              return deleteConfirm;
            },
            key: Key(model.allProducts[index].title),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                print('Swiped end to start.');

                //acually delete the product.
                model.selectProduct(model.allProducts[index].id);
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
