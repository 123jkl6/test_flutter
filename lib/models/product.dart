import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final String image;
  final double price;
  final String userEmail;
  final String userId;
  final bool isFavorite;

  Product({
    this.id,
    @required this.title,
    @required this.description,
    @required this.image,
    @required this.price,
    @required this.userEmail,
    @required this.userId,
    this.isFavorite=false//default false, not required property. 
  });

  String toString(){
    return '{"title":"$title","description":"$description","image":"$image","price":"$price"}';
  }
}