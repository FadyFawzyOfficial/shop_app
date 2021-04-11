import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _expiryTimer;

  bool get isAuthenticated => token != null;

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) return _token;
    return null;
  }

  String get userId => _userId;

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
      _autoLogout();
      notifyListeners();

      // Store my login data on the device in hte shared preferences.
      final prefs = await SharedPreferences.getInstance();
      // We complex data by the way, wo we use json.encode and encode a map into
      // JSON because JSON is always a String.
      final String userData = json.encode({
        'token': _token,
        'userId': _userId,
        // to have that standarized date formate.
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  // It will return a boolean because it should singal whether we were successful
  // when we try to automatically log the user in.
  // So, we are successful if we find a token and that token is still valid of
  // if we were not successful.
  Future<bool> tryAutoLogin() async {
    // Access the SharedPreferences.
    final prefs = await SharedPreferences.getInstance();

    // If the SharedPreferences doesn't contain the user data, then there is no data stored.
    if (prefs == null || !prefs.containsKey('userData')) return false;

    // If we do have that user data key, we know that we can at least get a token
    // It might still be an invalid token which already expired in the meantime,
    // but we can get some data.
    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;

    // From the extracted user data, we can get the expiry date because we want to
    // check that date and see whether it still is valid or not.
    // By using DateTime.parse() which works because we stored the date as an
    // ISO8601String to get DateTime Object.
    final expiryDate = DateTime.parse(extractedData['expiryDate']);

    // Check if expiry date is before the time now, we know the token is not valid
    // and we can return false here and we don't need to continue, we certainly
    // have no valid token because the expiry date is in the past.
    if (expiryDate.isBefore(DateTime.now())) return false;

    // Here, If we reach here that means we have a valid token because the expiry
    // date now is in the future and this is now when we want to reinitialize
    // all auth properties up there.
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    // call autoLogout to set that timer again.
    _autoLogout();
    // Importatnt to return true.
    return true;
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

  // So, here in logout(), I also get access to SharedPreferences by awaiting.
  // For that, we have to turn this into an async function which means it will
  // retrun a future that yields nothing.
  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_expiryTimer != null) {
      _expiryTimer.cancel();
      _expiryTimer = null;
    }
    notifyListeners();
    // When we logout, we want to clean all data you have in SharedPreferences.
    // We have to clear all data there to make suure that any data you had in there
    // is gone and is not getting used in the auto login thereafter.
    final prefs = await SharedPreferences.getInstance();
    // We can call remove() and pass in the key what we want to remove.
    // This will be good if we storing multiple things in the SharedPreferences,
    // which we don't all want to delete if we're logging out.
    // prefs.remove('userData');

    // But if I know I only store the user data there, I can also just call clear().
    // This will delete all your app's data from the SharedPreferences.
    prefs.clear();
  }

  void _autoLogout() {
    if (_expiryTimer != null) _expiryTimer.cancel();
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _expiryTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
