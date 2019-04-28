import 'package:flutter/material.dart';

import './product_manager.dart';
import './pages/auth.dart';
import './pages/product.dart';
import './pages/products.dart';
import './pages/manage_products.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final List<Map<String, String>> _products = [];

  @override
  void initState() {
    super.initState();
  }

  void _addProduct(Map<String, String> product) {
    setState(() {
      _products.add(product);
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple),
      // '/' and home are reserved, use one or the other.
      //home: AuthPage(),
      routes: {
        '/': (BuildContext context) {
          return ProductsPage(
            products: _products,
            addProduct: _addProduct,
            deleteProduct: _deleteProduct,
          );
        },
        '/admin': (BuildContext context) {
          return ManageProducts();
        }
      },
      onGenerateRoute: (RouteSettings settings) {
        final List<String> pathElements = settings.name.split('/');
        if (pathElements[0] != '') {
          return null;
        }
        if (pathElements[1] == 'product') {
          final int index = int.parse(pathElements[2]);
          return MaterialPageRoute<bool>(builder: (context) {
            return ProductPage(
              title: _products[index]['title'],
              imageUrl: _products[index]['image'],
            );
          });
        }
        return null; 
      },
      onUnknownRoute: (RouteSettings settings){
        return MaterialPageRoute(builder:(BuildContext context){
          return ProductsPage(
            products: _products,
            addProduct: _addProduct,
            deleteProduct: _deleteProduct,
          );
        });
      },
    );
  }
}
