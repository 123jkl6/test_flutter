import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';

import '../models/product.dart';
import '../models/location_data.dart';

import '../widgets/helpers/ensure-visible.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../widgets/form_input/location.dart';
import '../widgets/form_input/image.dart';

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
    'image': null,
    'location': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //focus nodes
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _priceTextController = TextEditingController();

  Widget _buildTitleField(Product product) {
    if (product == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.title;
    }
    // } else if (product != null && _titleTextController.text.trim() != ''){
    //   _titleTextController.text=_titleTextController.text;
    // } else if (product == null && _titleTextController.text.trim()!='') {
    //   _titleTextController.text = _titleTextController.text;
    // } else {
    //   _titleTextController.text = '';
    // }
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
          focusNode: _titleFocusNode,
          decoration: InputDecoration(labelText: 'Product Name'),
          controller: _titleTextController,
          validator: (String value) {
            if (value.isEmpty || value.length < 5) {
              return "Product name is required and should be 5+ characters long. ";
            }
          },
          onSaved: (String value) {
            print('title' + value);

            _formData['title'] = _titleTextController.text.trim();
          }),
    );
  }

  Widget _buildDescriptionField(Product product) {
    if (product == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (product != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = product.description;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
          focusNode: _descriptionFocusNode,
          decoration: InputDecoration(labelText: 'Product Description'),
          maxLines: 4,
          controller: _descriptionTextController,
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
    if (product == null && _priceTextController.text.trim() == '') {
      _priceTextController.text = '';
    } else if (product != null && _priceTextController.text.trim() == '') {
      _priceTextController.text = product.price.toString();
    }
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
          focusNode: _priceFocusNode,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Product Price'),
          controller: _priceTextController,
          validator: (String value) {
            if (value.isEmpty ||
                !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
              return "Price is required and should be a number. ";
            }
          },
          onSaved: (String value) {
            print('price' + value);
          }),
    );
  }
  // pointless now to build switch
  // Widget _buildSwitch() {
  //   return Switch(
  //     value: true,
  //     onChanged: (bool value) {
  //       print('Switch ' + value.toString());
  //     },
  //   );
  // }

  Widget _buildSaveButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(
              child: AdaptiveProgressIndicator())
          : RaisedButton(
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryColorLight,
              child: Text('Save'),
              onPressed: () => saveAction(model.addProduct, model.updateProduct,
                  model.selectProduct, model.selectedProduct),
            );
    });
  }

  void _setLocation(LocationData locationData) {
    _formData['location'] = locationData;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void saveAction(Function addProduct, Function updateProduct,
      Function selectProduct, Product product) {
    if (!_formKey.currentState.validate() ||
        _formData['image'] == null && product == null) {
      //stop executing if validation fails.
      return;
    }
    _formKey.currentState.save();
    print(_formData.toString());
    if (product == null) {
      addProduct(
        title: _titleTextController.text.trim(),
        description: _descriptionTextController.text.trim(),
        image: _formData['image'],
        price: double.parse(
            _priceTextController.text.replaceFirst(RegExp(r","), ".").trim()),
        locationData: _formData['location'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/home').then((_) =>
              selectProduct(
                  null)); //reset selectedIndex only after rebuilding the new page
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong.'),
                  content: Text('Please try again later'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Okay')),
                  ],
                );
              });
        }
      });
    } else {
      updateProduct(
        title: _titleTextController.text.trim(),
        description: _descriptionTextController.text.trim(),
        image: _formData['image'],
        price: double.parse(
            _priceTextController.text.replaceFirst(RegExp(r","), ".").trim()),
        locationData: _formData['location'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/home').then((_) =>
              selectProduct(
                  null)); //reset selectedIndex only after rebuilding the new page
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Something went wrong.'),
                  content: Text('Please try again later'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Okay')),
                  ],
                );
              });
        }
      });
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
                LocationInput(_setLocation, product),
                SizedBox(height: 10.0),
                ImageInput(setImage: _setImage, product: product),
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

      return model.selectedProductIndex == -1
          ? pageContent
          : Scaffold(
              appBar: AppBar(
                title: Text('Edit Product'),
              ),
              body: pageContent);
    });
  }
}
