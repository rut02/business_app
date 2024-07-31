//login_provider.dart
import 'package:flutter/material.dart';
import 'package:app_card/models/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  Login? _login;

  Login? get login => _login;

  void setLogin(Login? login) {
    _login = login;
    notifyListeners();
  }

  void logout() async {
    _login = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginData');
    notifyListeners();
  }
}
