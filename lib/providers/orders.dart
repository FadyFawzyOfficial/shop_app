import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  // When using async, the function which you use it always returns a future,
  // that future meight then not yield anything in the end but it always returns a future
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url =
        'https://shop-app-462f5-default-rtdb.europe-west1.firebasedatabase.app/orders';

    // We don't have to return future anymore because we automatically have this all wrapped
    // into a future and that future will also be returned automatically,
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'products': List<dynamic>.from(
              cartProducts.map((cartProduct) => cartProduct.toJson())),
          'dateTime': DateTime.now().toString(),
        }),
      );

      print(json.decode(response.body));
      final newOrder = OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: DateTime.now(),
      );
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (error) {
      print(error);
      // Throw the error to handle it in Widget level
      throw error;
    }
  }
}
