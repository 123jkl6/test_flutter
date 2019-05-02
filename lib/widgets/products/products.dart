import 'package:flutter/material.dart';

import './product_card.dart';

class Products extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  Products({this.products}) {
    print('constructed product widget ' + products.toString());
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return ProductCard(product: products[index], index: index);
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