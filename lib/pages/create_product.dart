import 'package:flutter/material.dart';

class CreateProductPage extends StatefulWidget {
  final Function addProduct;

  CreateProductPage({this.addProduct});

  @override
  State<StatefulWidget> createState() {
    return _CreateProductPageState();
  }
}

class _CreateProductPageState extends State<CreateProductPage> {
  String _productName = '';
  String _description = '';
  double _priceValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: ListView(children: <Widget>[
        TextField(
            decoration: InputDecoration(labelText: 'Product Name'),
            onChanged: (String value) {
              setState(() {
                _productName = value;
              });
            }),
        TextField(
            decoration: InputDecoration(labelText: 'Product Description'),
            maxLines: 4,
            onChanged: (String value) {
              setState(() {
                _description = value;
              });
            }),
        TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Product Price'),
            onChanged: (String value) {
              setState(() {
                _priceValue = double.parse(value);
              });
            }),
        SizedBox(height: 10.0),
        Switch(
          value: true,
          onChanged: (bool value){
            print('Switrch '+value.toString());
          },
        ),
        RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor:Theme.of(context).primaryColorLight,
            child: Text('Save'),
            onPressed: () {
              print(_productName + ' is being saved.');
              final Map<String, dynamic> product = {
                'title': _productName,
                'description': _description,
                'price': _priceValue,
                'image': 'assets/food.jpg'
              };
              widget.addProduct(product);
              Navigator.pushReplacementNamed(context, '/');
            })
      ]),
    );
  }
}
