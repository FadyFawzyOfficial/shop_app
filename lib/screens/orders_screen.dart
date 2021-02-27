import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Just to be sure it's first time to open the Orders Screen
  // var _isInit = true;

  @override
  void initState() {
    // In initState, all these of context things don't work
    // Like ModalRoute.of(context) and so on ...
    // Because the widget is not fully wired up with everything here.
    // So therefore we can't do that here.

    // Important: If you add listen: false, you CAN use this in initState()!
    // Workarounds are only needed if you don't set listen to false.
    // Provider.of<Orders>(context).fetchOrders(); // WON'T WORK!

    // => First Approach
    Future.delayed(Duration.zero).then((_) {
      // With listen: false, you could also make that method call WITHOUT the
      // Future delayed(...) workaround too!
      Provider.of<Orders>(context, listen: false).fetchOrders();
    });
    super.initState();
  }

  // => Second Approach
  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     Provider.of<Orders>(context).fetchOrders();
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: orderData.orders.length,
        itemBuilder: (context, index) => OrderItem(orderData.orders[index]),
      ),
    );
  }
}
