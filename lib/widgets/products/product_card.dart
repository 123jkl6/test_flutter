import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../scoped_models/main.dart';

import '../../models/product.dart';

import './price_tag.dart';
import './address_tag.dart';
import './user_tag.dart';
import '../ui_elements/title_default.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({@required this.product}) {
    print(product);
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductItem(context);
  }

  Widget _buildTitlePriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(
          flex: 10,
          child: TitleDefault(title: product.title),
        ),
        Flexible(
          flex:10,
          child:PriceTag(product.price.toString()),
        ),
      ],
    );
  }

  Widget _buildButtonBar(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            color: Theme.of(context).accentColor,
            onPressed: () {
              print(product.title + ' details pressed. ');
              model.selectProduct(product.id);
              Navigator.pushNamed<bool>(context, '/product/' + product.id).then(
                  (_) => model.selectProduct(
                      null)); //reset in the then block to unselect product when pressing back button
            },
          ),
          IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            color: Colors.red,
            onPressed: () {
              print(product.title + ' favorite pressed. ');
              model.selectProduct(product.id);
              model.toggleFavoriteStatus();
              //deselect product
              model.selectProduct(null);
            },
          )
        ],
      );
    });
  }

  Widget _buildProductItem(BuildContext context) {
    return Card(
        child: Column(
      children: <Widget>[
        Hero(
          //does nothing
          tag: product.id,
          child: FadeInImage(
              image: NetworkImage(product.image),
              height: 300.0,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 700),
              placeholder: AssetImage('assets/food.jpg')),
        ),
        Container(
          //margin:EdgeInsets.symmetric(vertical:10.0),
          margin: EdgeInsets.only(top: 10.0),
          //padding:EdgeInsets.only(top:10.0),
          //color:Colors.red,
          child: _buildTitlePriceRow(),
        ),
        SizedBox(height: 8.0),
        AddressTag(address: product.location.address),
        UserTag(user: product.userEmail),
        _buildButtonBar(context),
      ],
    ));
  }
}
