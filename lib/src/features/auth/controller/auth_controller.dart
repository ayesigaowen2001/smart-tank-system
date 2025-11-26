import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? currentUser;
  bool isLoading = false;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final user = await _authService.login(email, password);

    isLoading = false;
    notifyListeners();

    if (user != null) {
      currentUser = user;
      return true;
    }

    return false;
  }
}
