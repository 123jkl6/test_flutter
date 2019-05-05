import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/user.dart';

mixin ConnectedProductsModel on Model {

 final List<Product> _products = [
    Product(
        title: 'First Product',
        description:
            'This is added so the list would not be empty initially. This product awesome.\n This product is superbly awesome.',
        price: 12.99,
        image: 'assets/food.jpg',
        userEmail: 'nicholasngchuxu@gmail.com',
        userId: 'admin',
        )
  ];
  User _authenticatedUser;
  int _selectedProductIndex;

    void addProduct({String title, String description, String image, double price}) {
      final Product product = Product(
        title:title,
        description:description,
        image:image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,
      );
    _products.add(product);
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



  void updateProduct({String title, String description, String image, double price}) {
    final Product product = Product(title:title,
        description:description,
        image:image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id,);

    _products[_selectedProductIndex] = product;
  }

  void deleteProduct() {
    _products.removeAt(_selectedProductIndex);
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;

    //add additional check before notifying listeners
    //This is because page is still in animation while pressing back. 
    if (index!=null){
      notifyListeners();
    }
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
  void login(String email, String password){
        //allow only one user and pass
    if (email != 'nicholasngchuxu@gmail.com' || password != 'admin123') {
      print('Not Authorized. ');
      return;
    }
    _authenticatedUser = User(id:'hardcoded',email:email,password:password);
  }
}