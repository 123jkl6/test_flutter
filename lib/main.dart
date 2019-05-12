import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';

import './scoped_models/main.dart';

import './pages/auth.dart';
import './pages/product.dart';
import './pages/products.dart';
import './pages/manage_products.dart';

void main() {
  //debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final MainModel model = MainModel();
    return ScopedModel<MainModel>(
      model: model, // only one instance in entire app
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepOrange,
          accentColor: Colors.deepPurple,
          fontFamily: 'Oswald',
          buttonColor: Colors.deepPurple,
        ),
        // '/' and home are reserved, use one or the other.
        //home: AuthPage(),
        routes: {
          '/': (BuildContext context) {
            return AuthPage();
          },
          '/home': (BuildContext context) {
            return ProductsPage(model);
          },
          '/admin': (BuildContext context) {
            return ManageProducts(model:model);
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
              return ProductPage(productIndex: index);
            });
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: (BuildContext context) {
            return ProductsPage(model);
          });
        },
      ),
    );
  }
}
