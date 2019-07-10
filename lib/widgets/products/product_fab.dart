import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:scoped_model/scoped_model.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:test_flutter/scoped_models/main.dart';

import '../../models/product.dart';

class ProductFab extends StatefulWidget {
  final Product product;

  ProductFab({this.product});

  @override
  State<StatefulWidget> createState() {
    return _ProductFabState();
  }
}

class _ProductFabState extends State<ProductFab> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              // can add delay or finish early in here
              curve: Interval(0.0, 1.0, curve: Curves.easeOut),
            ),
            child: FloatingActionButton(
                //required for multiple floating buttons per screen
                heroTag: 'contact',
                mini: true,
                onPressed: () async {
                  print("mailing to " + widget.product.userEmail);
                  final url = "mailto:${widget.product.userEmail}";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw "cannot launch mail";
                  }
                },
                child: Icon(Icons.mail)),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              // finish the favorite animation first to stagger
              curve: Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
            child: FloatingActionButton(
                //required for multiple floating buttons per screen
                heroTag: 'favorite',
                backgroundColor: Theme.of(context).cardColor,
                mini: true,
                onPressed: () {
                  model.selectProduct(widget.product.id);
                  model.toggleFavoriteStatus();
                  model.selectProduct(null);
                },
                child: Icon(
                  model.selectedProduct.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                )),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            //required for multiple floating buttons per screen
            heroTag: 'options',
            mini: true,
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget child) {
                  return Transform(
                      alignment: FractionalOffset.center,
                      transform:
                          Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                      child: Icon(_controller.isDismissed
                          ? Icons.more_vert
                          : Icons.close));
                }),
          ),
        ),
      ]);
    });
  }
}
