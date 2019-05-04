import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';

mixin ProductsModel on Model {
  final List<Product> _products = [
    Product(
        title: 'First Product',
        description:
            'This is added so the list would not be empty initially. This product awesome.\n This product is superbly awesome.',
        price: 12.99,
        image: 'assets/food.jpg')
  ];

  int _selectedProductIndex;
  bool _showFavorites = false; //init to false.

  //dart specific
  List<Product> get products {
    //return a copy, because default is pass by reference
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorite).toList());
    }

    return products;
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

  void addProduct(Product product) {
    _products.add(product);
    //reset selected index
    _selectedProductIndex = null;
  }

  void updateProduct(Product product) {
    _products[_selectedProductIndex] = product;
    //reset selected index
    _selectedProductIndex = null;
  }

  void deleteProduct() {
    _products.removeAt(_selectedProductIndex);
    //reset selected index
    _selectedProductIndex = null;
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
    notifyListeners();
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
      isFavorite: newFavoriteStatus,
    );

    _products[_selectedProductIndex] = updatedProduct;
    //reset the index after everything.
    _selectedProductIndex = null;

    //inform ScopedModel there is a change in state
    notifyListeners();
  }

  void toggleDisplayFavorites() {
    _showFavorites = !_showFavorites;
    //inform ScopeModel , so that page can be re-rendered by calling build method again, 
    notifyListeners();
    _selectedProductIndex = null;
  }
}
