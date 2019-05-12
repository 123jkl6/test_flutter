import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

import '../models/product.dart';

import '../widgets/helpers/ensure-visible.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateProductPageState();
  }
}

class _CreateProductPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg',
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //focus nodes
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

  Widget _buildTitleField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
          focusNode: _titleFocusNode,
          decoration: InputDecoration(labelText: 'Product Name'),
          initialValue: product == null ? '' : product.title.toString(),
          validator: (String value) {
            if (value.isEmpty || value.length < 5) {
              return "Product name is required and should be 5+ characters long. ";
            }
          },
          onSaved: (String value) {
            print('title' + value);

            _formData['title'] = value;
          }),
    );
  }

  Widget _buildDescriptionField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
          focusNode: _descriptionFocusNode,
          decoration: InputDecoration(labelText: 'Product Description'),
          maxLines: 4,
          initialValue: product == null ? '' : product.description.toString(),
          validator: (String value) {
            if (value.isEmpty || value.length < 10) {
              return "Description is required and should be 10+ characters long. ";
            }
          },
          onSaved: (String value) {
            print('description' + value);

            _formData['description'] = value;
          }),
    );
  }

  Widget _buildPriceField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
          focusNode: _priceFocusNode,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Product Price'),
          initialValue: product == null ? '' : product.price.toString(),
          validator: (String value) {
            if (value.isEmpty ||
                !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
              return "Price is required and should be a number. ";
            }
          },
          onSaved: (String value) {
            print('price' + value);

            _formData['price'] = double.parse(value);
          }),
    );
  }

  Widget _buildSwitch() {
    return Switch(
      value: true,
      onChanged: (bool value) {
        print('Switch ' + value.toString());
      },
    );
  }

  Widget _buildSaveButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryColorLight,
              child: Text('Save'),
              onPressed: () => saveAction(model.addProduct, model.updateProduct,
                  model.selectProduct, model.selectedProduct),
            );
    });
  }

  void saveAction(Function addProduct, Function updateProduct,
      Function selectProduct, Product product) {
    if (!_formKey.currentState.validate()) {
      //stop executing if validation fails.
      return;
    }
    _formKey.currentState.save();
    print(_formData['title'] + ' is being saved.');

    if (product == null) {
      addProduct(
        title: _formData['title'],
        description: _formData['description'],
        image: _formData['image'],
        price: _formData['price'],
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/home').then((_) =>
            selectProduct(
                null)); //reset selectedIndex only after rebuilding the new page
      });
    } else {
      updateProduct(
        title: _formData['title'],
        description: _formData['description'],
        image: _formData['image'],
        price: _formData['price'],
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/home').then((_) =>
            selectProduct(
                null)); //reset selectedIndex only after rebuilding the new page
      });;
    }
  }

  Widget buildGestureDetector() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return GestureDetector(
        onTap: () {
          saveAction(model.addProduct, model.updateProduct, model.selectProduct,
              model.selectedProduct);
        },
        child: Container(
          color: Colors.green,
          padding: EdgeInsets.all(5.0),
          child: Text('MyButton'),
        ),
      );
    });
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    print(targetPadding);

    return GestureDetector(
      onTap: tapAnywhere,
      child: Container(
        width: targetWidth,
        margin: EdgeInsets.all(10.0),
        //List view by default takes full available space.
        child: Form(
          key: _formKey,
          child: ListView(
              padding: EdgeInsets.symmetric(horizontal: targetPadding / 2.0),
              children: <Widget>[
                _buildTitleField(product),
                _buildDescriptionField(product),
                _buildPriceField(product),
                SizedBox(height: 10.0),
                _buildSwitch(),
                _buildSaveButton(),
              ]),
        ),
      ),
    );
  }

  void tapAnywhere() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final product = model.selectedProduct;
      final Widget pageContent = _buildPageContent(context, product);

      return model.selectedProductIndex == null
          ? pageContent
          : Scaffold(
              appBar: AppBar(
                title: Text('Edit Product'),
              ),
              body: pageContent);
    });
  }
}
