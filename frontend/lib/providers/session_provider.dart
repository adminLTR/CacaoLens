import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider extends ChangeNotifier {
  bool _isGuest = true;
  String? _userName;
  String? _userEmail;

  bool get isGuest => _isGuest;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    _isGuest = token == null || token.isEmpty;
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    notifyListeners();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_last_name');
    await prefs.remove('user_birthdate');

    _isGuest = true;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }
}
