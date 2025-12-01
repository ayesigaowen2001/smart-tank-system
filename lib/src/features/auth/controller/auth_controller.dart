import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? currentUser;
  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await _authService.login(email, password);

    isLoading = false;
    notifyListeners();

    if (user != null) {
      currentUser = user;
      return true;
    }

    errorMessage = "Login failed. Please check your credentials.";
    return false;
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final user = await _authService.signInWithGoogle();

    isLoading = false;
    notifyListeners();

    if (user != null) {
      currentUser = user;
      return true;
    }

    errorMessage = "Google sign-in failed.";
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    currentUser = null;
    errorMessage = null;
    notifyListeners();
  }

  // Check if user is already signed in
  Future<void> checkSignInStatus() async {
    final googleUser = await _authService.getSignedInUser();
    if (googleUser != null) {
      // Optionally sync with backend
      notifyListeners();
    }
  }

  bool get isSignedIn => currentUser != null;
}
