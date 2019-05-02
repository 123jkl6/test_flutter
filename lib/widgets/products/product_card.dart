import 'package:flutter/material.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;

  ProductCard({this.product, this.index});

  @override
  Widget build(BuildContext context) {
    return _buildProductItem(context, index);
  }

  Widget _buildTitlePriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
          flex: 10,
          child: TitleDefault(title: product['title']),
        ),
        PriceTag(product['price'].toString()),
      ],
    );
  }

  Widget _buildButtonBar(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          color: Theme.of(context).accentColor,
          onPressed: () {
            print(product['title'] + ' details pressed. ');
            Navigator.pushNamed<bool>(context, '/product/' + index.toString());
          },
        ),
        IconButton(
          icon: Icon(Icons.favorite_border),
          color: Colors.red,
          onPressed: () {
            print(product['title'] + ' favorite pressed. ');
          },
        ),
      ],
    );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
        child: Column(
      children: <Widget>[
        Image.asset(product['image']),
        Container(
          //margin:EdgeInsets.symmetric(vertical:10.0),
          margin: EdgeInsets.only(top: 10.0),
          //padding:EdgeInsets.only(top:10.0),
          //color:Colors.red,
          child: _buildTitlePriceRow(),
        ),
        SizedBox(width: 20.0),
        AddressTag(address: 'Union Square, San Francisco'),
        _buildButtonBar(context),
      ],
    ));
  }
}
