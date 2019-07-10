import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../scoped_models/main.dart';

import '../../models/product.dart';

import './product_card.dart';

class Products extends StatelessWidget {
  Products() {
    print('constructed product widget ');
  }

  Widget _buildProductItem(Product product) {
    return ProductCard(product: product);
  }

  Widget _buildProductList(List<Product> products) {
    print(products.length);
    products.forEach((element){print(element.toString());});
    Widget productCards;

    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
         return  _buildProductItem(products[index]);
        },
        itemCount: products.length,
      );
    } else {
      productCards = Container(child: Text('Empty'),);
    }

    return productCards;
  }

  // Widget _builder(BuildContext context, Widget child, ProductsModel model) {
  //   return _buildProductList(model.products);
  // }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return _buildProductList(model.displayedProducts);
    });
  }
}
