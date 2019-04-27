import 'package:flutter/material.dart';

import './pages/product.dart';

class Products extends StatelessWidget{
  final List<String> products;

  Products(this.products){
    print('constructed product widget.'+products.toString());
  }

  Widget _buildProductItem(BuildContext context, int index){
    return Card(
                child: Column(
                  children: <Widget>[
                    Image.asset('assets/food.jpg'),
                    Text(products[index]),
                    ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child:Text('Details'),
                          onPressed: () {
                            print(products[index]+' details pressed. ');
                            Navigator.push(context,MaterialPageRoute(builder:(context){
                              return ProductPage();
                            }));
                          },
                          )
                      ],
                    )
                  ],
                  )
                );
  }

  @override
  Widget build(BuildContext context) {
    return products.length > 0 ? ListView.builder(
            itemBuilder: _buildProductItem,
            itemCount: products.length,
            ) : Center(child : Text('No products to be displayed. Add products to view. '));
  }

}
