import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:map_view/map_view.dart';

import './scoped_models/main.dart';

import './models/product.dart';
import './shared/keys.dart';

import './pages/auth.dart';
import './pages/product.dart';
import './pages/products.dart';
import './pages/manage_products.dart';

import './widgets/helpers/custom_route.dart';

import './shared/adaptive_theme.dart';

void main() {
  //debugPaintSizeEnabled = true;
  MapView.setApiKey(Keys.geoApi);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.authenticateOnStartup();
    _model.userSubject.listen((isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD MAIN');
    return ScopedModel<MainModel>(
      model: _model, // only one instance in entire app
      child: MaterialApp(
        theme: getAdaptiveThemeData(context),
        // '/' and home are reserved, use one or the other.
        //home: AuthPage(),
        routes: {
          '/': (BuildContext context) {
            return !_isAuthenticated ? AuthPage() : ProductsPage(_model);
          },
          // '/home': (BuildContext context) {
          //   return ProductsPage(_model);
          // },product
          '/admin': (BuildContext context) {
            return !_isAuthenticated
                ? AuthPage()
                : ManageProducts(model: _model);
          }
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(builder: (context) {
              return AuthPage();
            });
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });
            //previous MaterialPageRoute impl
            // return MaterialPageRoute<bool>(builder: (context) {
            //   return ProductPage(product: product);
            // });
            return CustomRoute<bool>(
              builder: (BuildContext context) => !_isAuthenticated
                  ? AuthPage()
                  : ProductPage(product: product),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: (BuildContext context) {
            return ProductsPage(_model);
          });
        },
      ),
    );
  }
}
