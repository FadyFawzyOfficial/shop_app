import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    return Scaffold(
      // We don't set up an appBar anymore because instead, we will now manually
      // animate a widget from our body into the appBar over time.
      body: CustomScrollView(
        // 1. The fist step it that you replace you SingleChildScrollView here
        // with a CustomScrollView because you need more control over how scrolling
        // is handled because different things will now be scrolling or we need
        // to do different things when we scroll, we need to change that images
        // into the app bar.
        // Slivers are just scrollable areas on the screen.
        slivers: [
          // For The SliverAppBar, that's the thing which should dynamically
          // change inot the app bar, for that you need to configer it.
          SliverAppBar(
            // You five it an expandedHeight which is the height that should have
            // if it's not the app bar but the image.
            expandedHeight: 300,
            // I'll set pinned to true which means that the app bar will always
            // be visible when we scroll, it will not scroll out of view but
            // instead it will simpley change to an app bar and then stick at top.
            // and the rest of the content can scroll beneath taht.
            pinned: true,
            // We need to define the flexibleSpace property, and that's in the end
            // what should be inside of that app bar.
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              // That's the part which you'll not always see, that's the part which
              // you'll see if this is expanded and here, I want to have my image.
              // So it's here where we use this hero Widget with the iamge inside of it.
              // Becuase that is what should be visible if this app bar is expanded.
              background: Hero(
                // So here, we also use the hero widget, the same widget and the
                // same tag and of course, the tag sould now be equal.
                tag: productId,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            // The SliverList needs a delegate that tells it how to render the
            // content of the list.
            // We should use SliverChildListDelegate which you instantiate and
            // takes a list of the items (Widget) that should be part of sliver list.
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              Text(
                '\$${loadedProduct.price}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(height: 700),
            ]),
          )
        ],
      ),
    );
  }
}
