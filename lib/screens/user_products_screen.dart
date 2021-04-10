import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    print('rebuilding...');
    return Scaffold(
      appBar: AppBar(
        // const widgets won't get rebuilt because Flutter is able to detect
        // that they can't have changed
        title: const Text('Your Products'),
        actions: [
          IconButton(
            // const widgets won't get rebuilt because Flutter is able to detect
            // that they can't have changed
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          // Thanks to the future builder, fetch data when this first loads, when
          // this first builds and then whenever it rebuilds but it shouldn't
          // rebuild here, then we either show the progress indicator or once
          // that's done, our main page with the surrounding refresh indicator.
          // there we can refresh products
          child: FutureBuilder(
            future: _refreshProducts(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              if (snapshot.error != null)
                // Do error handling stuff here
                return Center(child: Text('An error occurred!'));
              else
                return Consumer<Products>(
                  builder: (context, productsData, _) => ListView.builder(
                    itemCount: productsData.items.length,
                    itemBuilder: (_, index) => Column(
                      children: [
                        UserProductItem(
                          productsData.items[index].id,
                          productsData.items[index].title,
                          productsData.items[index].imageUrl,
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                );
            },
          ),
        ),
      ),
    );
  }
}
