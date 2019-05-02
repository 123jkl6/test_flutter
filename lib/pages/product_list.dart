import 'package:flutter/material.dart';

import './product_edit.dart';

class ProductListPage extends StatelessWidget {
  final Function updateProduct;
  final List<Map<String, dynamic>> products;

  ProductListPage({this.updateProduct, this.products});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          //leading: Image.asset(products[index]['image']),
          title: Text(products[index]['title']),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              print('Edit pressed. ');
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return ProductEditPage(
                    updateProduct: updateProduct,
                    productIndex: index,
                    product: products[index]);
              }));
            },
          ),
        );
      },
      itemCount: products.length,
    );
  }
}
