import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import 'dart:convert';

import '../models/auth.dart';
import '../models/product.dart';
import '../models/user.dart';

mixin ConnectedProductsModel on Model {
  final String _url = 'https://ngtestflutter.firebaseio.com/';

  List<Product> _products = [
    // Product(
    //   title: 'First Product',
    //   description:
    //       'This is added so the list would not be empty initially. This product awesome.\n This product is superbly awesome.',
    //   price: 12.99,
    //   image: 'assets/food.jpg',
    //   userEmail: 'nicholasngchuxu@gmail.com',
    //   userId: 'admin',
    //)
  ];
  User _authenticatedUser;
  String _selectedProductId;
  bool _isLoading = false;
}

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false; //init to false.

  //dart specific
  List<Product> get allProducts {
    //return a copy, because default is pass by reference
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorite).toList());
    }

    return allProducts;
  }

  String get selectedProductId {
    return _selectedProductId;
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selectedProductId;
    });
  }

  Product get selectedProduct {
    if (_selectedProductId == null) {
      return null;
    }
    return _products.firstWhere((Product el) {
      return el.id == _selectedProductId;
    });
  }

  bool get showFavoritesMode {
    return _showFavorites;
  }

  Future<bool> addProduct(
      {String title, String description, String image, double price}) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/8/88/Philippine_Food.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    try {
      //await calls then
      final http.Response response = await http.post(
          _url + 'products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      _isLoading = false;
      final Product product = Product(
        id: responseData['id'],
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
      );
      _products.add(product);
      notifyListeners();
      _selectedProductId = null;
      return true;
    } catch (error) {
      print(error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(
      {String title, String description, String image, double price}) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updatedData = {
      'title': title,
      'description': description,
      'image':
          'https://upload.wikimedia.org/wikipedia/commons/8/88/Philippine_Food.jpg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
    };
    return http
        .put(
            _url +
                'products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(updatedData))
        .then((http.Response response) {
      print(response);
      _isLoading = false;

      final Product product = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
      );

      _products[selectedProductIndex] = product;
      notifyListeners();

      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);

    //reset
    _selectedProductId = null;
    return http
        .delete(_url +
            'products/$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;

      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void selectProduct(String productId) {
    _selectedProductId = productId;

    //add additional check before notifying listeners
    //This is because page is still in animation while pressing back.
    if (_selectedProductId != null) {
      notifyListeners();
    }
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get(_url + 'products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      print(json.decode(response.body));

      _isLoading = false;
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);

      //case when no data is available
      if (productListData == null) {
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productData) {
        final Product product = Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          image: productData['image'],
          price: productData['price'],
          userEmail: productData['userEmail'],
          userId: productData['userId'],
        );
        fetchedProductList.add(product);
      });

      _products = fetchedProductList;
      notifyListeners();
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void toggleFavoriteStatus() async {
    final Product selectedProduct = _products[selectedProductIndex];
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    Product updatedProduct = Product(
      id: selectedProduct.id,
      title: selectedProduct.title,
      description: selectedProduct.description,
      image: selectedProduct.image,
      price: selectedProduct.price,
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id,
      isFavorite: newFavoriteStatus,
    );
    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          _url +
              'products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(_url +
          'products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        image: selectedProduct.image,
        price: selectedProduct.price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        isFavorite: !newFavoriteStatus,
      );
    }
    _products[selectedProductIndex] = updatedProduct;

    //inform ScopedModel there is a change in state
    notifyListeners();
  }

  void toggleDisplayFavorites() {
    _showFavorites = !_showFavorites;
    //inform ScopeModel , so that page can be re-rendered by calling build method again,
    notifyListeners();
  }
}

mixin UserModel on ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get authenticatedUser {
    return _authenticatedUser;
  }

  PublishSubject get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(
      String email, String password, AuthMode authMode) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    http.Response response;
    if (authMode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyAwsYQRLW5FZXnIsC1Yr39qowCkg2ePDBk',
        headers: {'Content-Type': 'application/json'},
        body: json.encode(authData),
      );
    } else {
      response = await http.post(
        "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyAwsYQRLW5FZXnIsC1Yr39qowCkg2ePDBk",
        headers: {'Content-Type': 'application/json'},
        body: json.encode(authData),
      );
    }

    _isLoading = true;
    bool hasError = true;
    final Map<String, dynamic> responseBody = json.decode(response.body);
    print(responseBody);
    String message = 'Service not available. ';
    if (responseBody.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded';
      _authenticatedUser = User(
          id: responseBody['localId'],
          email: email,
          token: responseBody['idToken']);
      setAuthTimeout(int.parse(responseBody['expiresIn']));
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('test_flutter_token', responseBody['idToken']);
      prefs.setString('test_flutter_user_email', email);
      prefs.setString('test_flutter_user_id', responseBody['localId']);
      prefs.setString('text_flutter_expiry_time', expiryTime.toIso8601String());
    } else if (responseBody['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Email not found.';
    } else if (responseBody['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Password is invalid. ';
    } else if (responseBody['error']['message'] == 'EMAIL_EXISTS') {
      message = 'Email already exists';
    }
    _isLoading = false;
    _userSubject.add(true);
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void authenticateOnStartup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('test_flutter_token');
    final String expiryTimeString = prefs.getString('test_flutter_expiry_time');
    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        //don't finish function
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('test_flutter_user_email');
      final String userId = prefs.getString('test_flutter_user_id');
      final tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
      notifyListeners();
    }
  }

  void logout() async {
    print('LOGOUT CALL FROM CONNECTED_PRODUCTS MODEL');
    _authenticatedUser = null;
    //clear timer like in javascript.
    _authTimer.cancel();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('test_flutter_token');
    prefs.remove('test_flutter_user_email');
    prefs.remove('test_flutter_user_id');
    _userSubject.add(false);
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
