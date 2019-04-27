import 'package:flutter/material.dart';

import './products.dart';
import './product_control.dart';

class ProductManager extends StatefulWidget {
  final String startingProduct;

  ProductManager({this.startingProduct}) {
    print('ProductManager constructor. ');
  }

  @override
  State<StatefulWidget> createState() {
    print('createdState in ProductManager');
    return _ProductManagerState();
  }
}

class _ProductManagerState extends State<ProductManager> {
  final List<String> _products = [];

  @override
  void initState() {
    print('initState ProductManager');
    //needs to be called.
    super.initState();

    if (widget.startingProduct != null){
      _products.add(widget.startingProduct);
    }
  }

  @override
  void didUpdateWidget(ProductManager oldWidget) {
    print('didUpdateWidget ProuctManager');
    super.didUpdateWidget(oldWidget);
  }

  void _addProduct(String product) {
    setState(() {
      _products.add('Add Food Tester.');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build ProductManager');
    return Column(
      children: [
        Container(margin: EdgeInsets.all(10.0), 
                  child: ProductControl(_addProduct),
                  ),
        Expanded(child:Products(_products)),
      ],
    );
  }
}
