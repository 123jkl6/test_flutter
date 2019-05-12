import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'dart:convert';

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
  int _selectedProductIndex;
  bool _isLoading = false;

  Future<Null> addProduct(
      {String title, String description, String image, double price}) {
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

    return http
        .post(_url + 'products.json', body: json.encode(productData))
        .then((http.Response response) {
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
    });
  }
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

  int get selectedProductIndex {
    return _selectedProductIndex;
  }

  Product get selectedProduct {
    if (_selectedProductIndex == null) {
      return null;
    }
    return _products[_selectedProductIndex];
  }

  bool get showFavoritesMode {
    return _showFavorites;
  }

  Future<Null> updateProduct(
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
        .put(_url + 'products/${selectedProduct.id}.json',
            body: json.encode(updatedData))
        .then((http.Response response) {
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

      _products[_selectedProductIndex] = product;
       notifyListeners();
    });
   
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(_selectedProductIndex);

    //reset
    _selectedProductIndex=null; 
    http.delete(_url+'products/$deletedProductId.json')
    .then((http.Response response){
      _isLoading = false;
      
      notifyListeners();
    });
    
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;

    //add additional check before notifying listeners
    //This is because page is still in animation while pressing back.
    if (index != null) {
      notifyListeners();
    }
  }

  void fetchProducts() {
    _isLoading = true;
    notifyListeners();

    http.get(_url + 'products.json').then((http.Response response) {
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
    });
  }

  void toggleFavoriteStatus() {
    final Product selectedProduct = _products[_selectedProductIndex];
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
      title: selectedProduct.title,
      description: selectedProduct.description,
      image: selectedProduct.image,
      price: selectedProduct.price,
      userEmail: _authenticatedUser.email,
      userId: _authenticatedUser.id,
      isFavorite: newFavoriteStatus,
    );

    _products[_selectedProductIndex] = updatedProduct;

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
  void login(String email, String password) {
    //allow only one user and pass
    if (email != 'nicholasngchuxu@gmail.com' || password != 'admin123') {
      print('Not Authorized. ');
      return;
    }
    _authenticatedUser =
        User(id: 'hardcoded', email: email, password: password);
  }
}

mixin UtilityModel on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
