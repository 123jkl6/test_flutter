import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:mime/mime.dart';

import 'dart:convert';

import '../models/auth.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/location_data.dart';
import '../shared/keys.dart';

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

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-ngtestflutter.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] =
        'Bearer ${_authenticatedUser.token}';
    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Image upload failed.');
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addProduct(
      {String title,
      String description,
      File image,
      double price,
      LocationData locationData}) async {
    _isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);
    if (uploadData == null) {
      print('Upload failed');
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'loc_lat': locationData.latitude,
      'loc_lng': locationData.longitude,
      'loc_address': locationData.address,
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
        image: uploadData['imageUrl'],
        imagePath: uploadData['imagePath'],
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        location: locationData,
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
      {String title,
      String description,
      File image,
      double price,
      LocationData locationData}) async {
    _isLoading = true;
    notifyListeners();
    String imageUrl = selectedProduct.image;
    String imagePath = selectedProduct.imagePath;
    if (image != null) {
      final uploadData = await uploadImage(image);
      if (uploadData == null) {
        print('Upload failed');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      //reassign
      imageUrl = uploadData['imageUrl'];
      imagePath = uploadData['imagePath'];
    }
    final Map<String, dynamic> updatedData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
      'loc_lat': locationData.latitude,
      'loc_lng': locationData.longitude,
      'loc_address': locationData.address,
    };
    try {
      final http.Response response = await http.put(
          _url +
              'products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updatedData));

      print(response);
      _isLoading = false;

      final Product product = Product(
        id: selectedProduct.id,
        title: title,
        description: description,
        image: imageUrl,
        imagePath: imagePath,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        location: locationData,
        isFavorite: selectedProduct.isFavorite,
      );

      _products[selectedProductIndex] = product;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
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

  Future<Null> fetchProducts({onlyForUser = false, clearExisting = false}) {
    _isLoading = true;
    //only clear on productlistpage, not the main
    if (clearExisting){
      _products = [];
    }
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
          image: productData['imageUrl'],
          imagePath: productData['imagePath'],
          price: productData['price'],
          userEmail: productData['userEmail'],
          userId: productData['userId'],
          location: LocationData(
              address: productData['loc_address'],
              latitude: productData['loc_lat'],
              longitude: productData['loc_lng']),
          isFavorite: productData['wishlistUsers'] == null
              ? false
              : (productData['wishlistUsers'] as Map<String, dynamic>)
                  .containsKey(_authenticatedUser.id),
        );
        fetchedProductList.add(product);
      });

      //filter
      _products = onlyForUser
          ? fetchedProductList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchedProductList;
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
      imagePath: selectedProduct.imagePath,
      price: selectedProduct.price,
      userEmail: selectedProduct.userEmail,
      userId: selectedProduct.id,
      location: selectedProduct.location,
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
        imagePath: selectedProduct.imagePath,
        price: selectedProduct.price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
        location: selectedProduct.location,
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
    print(authData);
    http.Response response;
    if (authMode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key='+Keys.authApi,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(authData),
      );
    } else {
      response = await http.post(
        "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key="+Keys.authApi,
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
      prefs.setString('test_flutter_expiry_time', expiryTime.toIso8601String());
    } else if (responseBody['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Email not found.';
    } else if (responseBody['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Password is invalid. ';
    } else if (responseBody['error']['message'] == 'EMAIL_EXISTS') {
      message = 'Email already exists';
    } else {
      message = 'An unknown error has occured. ';
    }
    _isLoading = false;
    if (!hasError) {
      _userSubject.add(true);
    }
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void authenticateOnStartup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('test_flutter_token');
    final String expiryTimeString = prefs.getString('test_flutter_expiry_time');
    final String userEmailString = prefs.getString('test_flutter_user_email');
    final String userIdString = prefs.getString('test_flutter_user_id');
    if (token != null &&
        expiryTimeString != null &&
        userEmailString != null &&
        userIdString != null) {
      //print(expiryTimeString);
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
    //reset on logout, so that selectedProductId is null upon relogin. 
    _selectedProductId = null;
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
