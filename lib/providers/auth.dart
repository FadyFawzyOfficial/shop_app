import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAzJJMVEpY26L0Zr9QjmZpW1ab1H2VTWuc';

    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    print(json.decode(response.body));
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
