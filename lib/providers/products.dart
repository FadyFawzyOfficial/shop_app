import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  static const productsUrl =
      'https://shop-app-462f5-default-rtdb.europe-west1.firebasedatabase.app/products.json';

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  final String authToken;
  final String authUserId;

  Products(this.authToken, this.authUserId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly)
    //   return _items.where((productItem) => productItem.isFavorite).toList();
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterSegment =
        filterByUser ? '&orderBy="ownerId"&equalTo="$authUserId"' : '';
    var url = '$productsUrl?auth=$authToken$filterSegment';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      // So that the following code doesn't run if extracted data is null and
      // return here to avoid that you run code which would fail if you have no data.
      if (extractedData == null) return;

      // When we fetch products, we of course also want to fetch data for the
      // favorite status according to each user.
      // So, We also fetch the favorite statuses before I transform products data.
      // Here because: I don't want to do that if we have no products.
      // So, I'll wait for the previous check (if statement).

      // It's time for antoher request where we get our favorite response.
      url =
          'https://shop-app-462f5-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$authUserId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'].toDouble(),
            imageUrl: value['imageUrl'],
            // If favoriteData is null, then this user has never favorited anything.
            // So then obviously every product will just be not a favorite, so we
            // set this to false.
            // If favoriteData isn't null, then the user has some favorite data
            // we can check for that productId(key here), but that productId still
            // might not exist (null). So, I want to user an alternative value if
            // it is null. With double question mark operator to use that value
            // and if it is null it will fallback to the value after the ?? marks.
            isFavorite:
                favoriteData == null ? false : favoriteData[key] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  // When using async, the function which you use it always returns a future,
  // that future meight then not yield anything in the end but it always returns a future
  Future<void> addProduct(Product product) async {
    final url = '$productsUrl?auth=$authToken';
    try {
      // We don't have to return future anymore because we automatically have this all wrapped
      // into a future and that future will also be returned automatically,
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'ownerId': authUserId,
        }),
      );
      // print(json.decode(response.body));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      // Throw the error to handle it in Widget level
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      // Since that's dynamic and not constant at compilation time, we can't use
      // const here anymore though, we have to use final.
      // Because this will only be final at runtime.
      final url =
          'https://shop-app-462f5-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    } else
      print('...');
  }

  Future<void> deleteProduct(String id) async {
    // You can use async await here if you want to,
    // but you can also do something which is known as optimistic updating.
    // Instead I immediately execute this because Dart doesn't block code
    // execution until this is done and moves ahead to this line before we have
    // a response from the server.
    final url =
        'https://shop-app-462f5-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json?auth=$authToken';
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    // For get and post, the HTTP package would have thrown an error and catchError()
    // method would've kicked off, but here (delete) that is not happening and
    // therefore I want to throw my own error if that's the case.
    final response = await http.delete(url);
    print(response.statusCode);
    // Check if response status code is greater than or equal than 400 which
    // means something went wrong and in that case, I want to throw my own error
    // and not continue with the following code.
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  void _toggleProductFavoriteStatus(Product product) {
    product.toggleFavoriteStatus();
    // To update (remove unfavorite item) the 'Only Favorites' Screen
    // immediately when unfavorite an item.
    notifyListeners();
  }

  Future<void> updateFavoriteStatus(String productId) async {
    // Get the index of the product with the given id
    final productIndex =
        _items.indexWhere((product) => product.id == productId);
    var product = _items[productIndex];
    // Check that if the product in the list or not?
    if (productIndex >= 0) {
      _toggleProductFavoriteStatus(product);
      final url =
          'https://shop-app-462f5-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$authUserId/$productId.json?auth=$authToken';
      final response = await http.put(
        url,
        body: json.encode(product.isFavorite),
      );
      // The HTTP package only throws its own error for get and post requests
      // if the server returns an error status code.
      // For patch, put, delete, it doesn't do that.
      print(response.statusCode);
      if (response.statusCode >= 400) {
        _toggleProductFavoriteStatus(product);
        throw HttpException('Could not update product.');
      }
      product = null;
    }
  }
}
