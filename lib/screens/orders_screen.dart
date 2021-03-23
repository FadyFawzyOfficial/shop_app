import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    // This print statement to be sure the build method should now build one time.
    print('building orders');
    // Don't set up the listener here for Orders data
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body:
          // FutureBuilder Widget takes a future and then automatically starts listening
          // to that. So it adds the then and the catch error method for you as developer.
          // And it takes a builder which will get the current snapshot to current state
          // of your future so that you can build different content based on what your future return.
          FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (snapshot.error != null)
            // Do error handling stuff here
            return Center(
              child: Text('An error occurred!'),
            );
          else
            // Use a consumer of the Orders data in here
            // In that case here, because only here I'm interested in order data.
            return Consumer<Orders>(
              // It will really jsut rebuild the parts that do need rebuilding.
              builder: (context, orderData, child) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (context, index) =>
                    OrderItem(orderData.orders[index]),
              ),
            );
        },
      ),
    );
  }
}
