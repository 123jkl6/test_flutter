import 'package:flutter/material.dart';

import './product_edit.dart';

class ProductListPage extends StatelessWidget {
  final Function updateProduct;
  final Function deleteProduct;
  final List<Map<String, dynamic>> products;

  ProductListPage({this.updateProduct, this.deleteProduct, this.products});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: Key(products[index]['title']),
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart) {
              print('Swiped end to start.');
              //acually delete the product. 
              deleteProduct(index);
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
                  backgroundImage: AssetImage(products[index]['image']),
                ),
                title: Text(products[index]['title']),
                subtitle: Text('\$${products[index]['price'].toString()}'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    print('Edit pressed. ');
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return ProductEditPage(
                          updateProduct: updateProduct,
                          productIndex: index,
                          product: products[index]);
                    }));
                  },
                ),
              ),
              Divider(
                color: Colors.black,
              )
            ],
          ),
        );
      },
      itemCount: products.length,
    );
  }
}
