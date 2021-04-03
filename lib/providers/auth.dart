import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuthenticated => token != null;

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAzJJMVEpY26L0Zr9QjmZpW1ab1H2VTWuc';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null)
        // What's the idea behind throwing an exception here?
        // We can of course now manage or handle that exception in the AuthScreen
        // which is where we're in the widget and where we can present something
        // to the user, show an alert to the user for example.
        throw HttpException(responseBody['error']['message']);

      _token = responseBody['idToken'];
      _userId = responseBody['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    // We return this future because this is the future which actualy wraps our
    // HTTP request and waits for it to complete.
    // So, in order to have our loading spinner work correctly, we want to return
    // the future which actually does the work.
    // Without return, we would also return a future but this wouldn't wait for
    // the future of authenticate to do its job.
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async =>
      _authenticate(email, password, 'signInWithPassword');
}
