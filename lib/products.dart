import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  Products(this.products) {
    print('constructed product widget ' + products.toString());
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
        child: Column(
      children: <Widget>[
        Image.asset(products[index]['image']),
        Container(
          //margin:EdgeInsets.symmetric(vertical:10.0),
          margin: EdgeInsets.only(top: 10.0),
          //padding:EdgeInsets.only(top:10.0),
          //color:Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(products[index]['title'],
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(width: 20.0),
              Container(
                padding:EdgeInsets.symmetric(horizontal:6.0,vertical:2.5),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius:BorderRadius.circular(5.0)
                  ),
                child: Text('USD\$ ${products[index]["price"].toString()}',
                    style: TextStyle(
                      fontSize: 20.0,
                      color:Colors.white
                    )),
              ),
            ],
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text('Details'),
              onPressed: () {
                print(products[index]['title'] + ' details pressed. ');
                Navigator.pushNamed<bool>(
                    context, '/product/' + index.toString());
              },
            )
          ],
        )
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return products.length > 0
        ? ListView.builder(
            itemBuilder: _buildProductItem,
            itemCount: products.length,
          )
        : Center(
            child: Text('No products to be displayed. Add products to view. '));
  }
}
