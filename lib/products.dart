import 'package:flutter/material.dart';

import './pages/product.dart';

class Products extends StatelessWidget {
  final List<Map<String, String>> products;
  final Function deleteProduct;

  Products(this.products,{this.deleteProduct}) {
    print('constructed product widget ' + products.toString());
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
        child: Column(
      children: <Widget>[
        Image.asset(products[index]['image']),
        Text(products[index]['title']),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text('Details'),
              onPressed: () {
                print(products[index]['title'] + ' details pressed. ');
                Navigator.pushNamed<bool>(context,'/product/'+index.toString()).then((bool value){
                  print(value);
                  if (value){
                    deleteProduct(index);
                  }
                });
              },
            )
          ],
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return products.length > 0
        ? ListView.builder(
            itemBuilder: _buildProductItem,
            itemCount: products.length,
          )
        : Center(
            child: Text('No products to be displayed. Add products to view. '));
  }
}
