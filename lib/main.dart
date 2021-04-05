import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screem.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        // How do we actually get the authToken (out of Auth class)
        // into our Products class?
        // Use ChangeNotifierProxyProvider which is Generic class<>
        // This allows you to set up a provider, which itself depends on another
        // provider which was defined before (Auth Provider).
        // 1st Generic argument: is the class that the type of data you depend on.
        // 2nd Generic argument: is the calss that the type of data will provide here.
        ChangeNotifierProxyProvider<Auth, Products>(
          // We pass null to create method because it just required.
          create: null,
          // So, the update here will receive that 'auth' object (1st Generic argument)
          // and whenever Auth Provider changes, this provider here will also be rebuilt.
          // Only this one, not the entire widget, not the other providers.
          // Because this 'auth' object is now dependent on Auth Provider.
          // So, it makes sense that this provider rebuilds and new products
          // object here would be built when auth changes instead of previous
          // state of products object (old products object).
          // So, pervious products object which passed (2nd Generic argument)
          // will update by returning a new object of type Products after
          // we pass an auth token.
          update: (context, auth, previousProducts) => Products(
            // Pass the user's auth token for outgoing HTTP requests of Prodcuts Provider.
            auth.token,
            // We have to make sure that when gets rebuild and we create a new
            // instance of Products, we don't lose all the data we had in there
            // before (previousProducts) because in Products Provider you mustn't
            // forget that you had a list of your products that was teh key thing
            // we were managing in there, the list of our items.
            // While it's first time to initialize Produts object, the previousProd ucts
            // will be null (not instantiated) with no items list at all.
            // So, this will create the products object with auth token and then
            // either with an empty list of products or with the previous items.
            //
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider(
          // For Efficiency: Use create: if you are creating a new instance
          // (is recommended more than .value Constructor)
          create: (BuildContext context) => Cart(),
        ),
        // 1st Generic Type (Auth): is our dependency.
        // 2nd Generic Type (Orders): is the value we're about to provide.
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (context, auth, previousOrders) => Orders(
            auth.token,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: auth.isAuthenticated ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
