import 'package:flutter/material.dart';

class ProductEditPage extends StatefulWidget {
  final Function addProduct;
  final Function updateProduct;
  final int productIndex;
  final Map<String, dynamic> product;

  ProductEditPage({this.addProduct, this.updateProduct,this.productIndex, this.product});

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

  Widget _buildTitleField() {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Product Name'),
        initialValue:
            widget.product == null ? '' : widget.product['title'].toString(),
        validator: (String value) {
          if (value.isEmpty || value.length < 5) {
            return "Product name is required and should be 5+ characters long. ";
          }
        },
        onSaved: (String value) {
          print('title' + value);

          _formData['title'] = value;
        });
  }

  Widget _buildDescriptionField() {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Product Description'),
        maxLines: 4,
        initialValue: widget.product == null
            ? ''
            : widget.product['description'].toString(),
        validator: (String value) {
          if (value.isEmpty || value.length < 10) {
            return "Description is required and should be 10+ characters long. ";
          }
        },
        onSaved: (String value) {
          print('description' + value);

          _formData['description'] = value;
        });
  }

  Widget _buildPriceField() {
    return TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Product Price'),
        initialValue:
            widget.product == null ? '' : widget.product['price'].toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
            return "Price is required and should be a number. ";
          }
        },
        onSaved: (String value) {
          print('price' + value);

          _formData['price'] = double.parse(value);
        });
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
    return RaisedButton(
        color: Theme.of(context).primaryColor,
        textColor: Theme.of(context).primaryColorLight,
        child: Text('Save'),
        onPressed: saveAction);
  }

  void saveAction() {
    if (!_formKey.currentState.validate()) {
      //stop executing if validation fails.
      return;
    }
    _formKey.currentState.save();
    print(_formData['title'] + ' is being saved.');

    if (widget.product == null){
      widget.addProduct(_formData);
    } else {
      widget.updateProduct(widget.productIndex,_formData);
    }
    Navigator.pushReplacementNamed(context, '/');
  }

  Widget buildGestureDetector() {
    return GestureDetector(
      onTap: saveAction,
      child: Container(
        color: Colors.green,
        padding: EdgeInsets.all(5.0),
        child: Text('MyButton'),
      ),
    );
  }

  void tapAnywhere() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    print(targetPadding);
    final Widget pageContent = GestureDetector(
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
                _buildTitleField(),
                _buildDescriptionField(),
                _buildPriceField(),
                SizedBox(height: 10.0),
                _buildSwitch(),
                _buildSaveButton(),
              ]),
        ),
      ),
    );

    return widget.product == null
        ? pageContent
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit Product'),
            ),
            body: pageContent);
  }
}
