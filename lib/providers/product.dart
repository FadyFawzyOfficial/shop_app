import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _reverseFavoriteValue() {
    isFavorite = !isFavorite;
    // To update (remove unfavorite item) the 'Only Favorites' Screen
    // immediately when unfavorite an item
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus() async {
    _reverseFavoriteValue();
    final url =
        'https://shop-app-462f5-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json';
    try {
      final response = await http.patch(
        url,
        body: json.encode(
          {
            'isFavorite': isFavorite,
          },
        ),
      );
      print(response.statusCode);
      if (response.statusCode >= 400) {
        _reverseFavoriteValue();
      }
    } catch (error) {
      _reverseFavoriteValue();
      throw HttpException('Could not update product.');
    }
  }
}
