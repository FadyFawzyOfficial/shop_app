import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart' show Cart;
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // To show loading indicator or not
  var _isLoading = false;

  void _saveOrder(Cart cart) {
    setState(() {
      _isLoading = true;
    });
    Provider.of<Orders>(context, listen: false)
        .addOrder(
      cart.items.values.toList(),
      cart.totalAmount,
    )
        .then((_) {
      cart.clear();
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount}',
                      style: TextStyle(
                          color:
                              // 'title' is deprecated and souldn't be used.
                              // The modern term is headline6.
                              Theme.of(context)
                                  .primaryTextTheme
                                  .headline6
                                  .color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  _isLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CircularProgressIndicator(),
                        )
                      : FlatButton(
                          child: Text('Order Now'.toUpperCase()),
                          textColor: Theme.of(context).primaryColor,
                          onPressed:
                              // disable 'Order Now' button if the cart is empty
                              cart.items.isEmpty
                                  ? null
                                  : () => _saveOrder(cart),
                        ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) => CartItem(
                cart.items.values.toList()[index].id,
                cart.items.keys.toList()[index],
                cart.items.values.toList()[index].price,
                cart.items.values.toList()[index].quantity,
                cart.items.values.toList()[index].title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
