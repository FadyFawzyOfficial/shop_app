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
  static const baseUrl =
      'https://shop-app-462f5-default-rtdb.europe-west1.firebasedatabase.app';

  final String authToken;
  final String authUserId;

  List<OrderItem> _orders = [];

  Orders(this.authToken, this.authUserId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    try {
      final response =
          await http.get('$baseUrl/orders/$authUserId.json?auth=$authToken');
      // print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      // So that the following code doesn't run if extracted data is null and
      // return here to avoid that you run code which would fail if you have no data.
      if (extractedData == null) return;

      // Clear the pervious orders list to refill it by fetching back end orders list.
      _orders.clear();

      extractedData.forEach((orderId, orderData) {
        _orders.insert(
            0,
            OrderItem(
              id: orderId,
              amount: orderData['amount'],
              products: List<CartItem>.from(orderData['products']
                  .map((cartItemJson) => CartItem.fromJson(cartItemJson))),
              dateTime: DateTime.parse(orderData['dateTime']),
            ));
      });
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // When using async, the function which you use it always returns a future,
  // that future meight then not yield anything in the end but it always returns a future
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // use one order's timestamp for local and server
    final timestamp = DateTime.now();

    // We don't have to return future anymore because we automatically have this all wrapped
    // into a future and that future will also be returned automatically,
    try {
      final response = await http.post(
        '$baseUrl/orders/$authUserId.json?auth=$authToken',
        body: json.encode({
          'amount': total,
          'products': List<dynamic>.from(
              cartProducts.map((cartProduct) => cartProduct.toJson())),
          // convert to an Iso8601String which is a uniform string
          // representation of dates,  which we can later easily convert back
          // into a DateTime object when we load this into Dart again.
          'dateTime': timestamp.toIso8601String(),
        }),
      );

      // I didn't get an error when i tried to add the order in the cart because
      // I haven't implemented error handling here.
      print(json.decode(response.body));
      final newOrder = OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timestamp,
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
