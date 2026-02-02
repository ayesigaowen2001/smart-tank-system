import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthService {
  final String baseUrl = "https://your-api-url.com"; // Replace later
  final bool useLocalAuth;
  late final GoogleSignIn _googleSignIn;

  /// When prototyping, set [useLocalAuth] = true to perform authentication locally.
  /// Local auth accepts ANY email as long as password == 'password'.
  AuthService({this.useLocalAuth = true}) {
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile',
      ],
    );
  }

  // Traditional email/password login
  Future<User?> login(String email, String password) async {
    // Local prototype auth (quick and insecure, for dev use only)
    if (useLocalAuth) {
      // Accept any email as long as the password is the easy prototype password
      if (password == 'password') {
        developer.log('Local login success for $email', name: 'AuthService');
        return User(id: 'local:$email', email: email, token: 'local-token');
      } else {
        developer.log('Local login failed for $email', name: 'AuthService');
        return null;
      }
    }

    // Remote auth (default behavior)
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        developer.log('Login success: $response', name: 'AuthService');
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (e, st) {
      developer.log('Login error: $e',
          name: 'AuthService', error: e, stackTrace: st);
    }
    return null;
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Get the Google ID token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // Send the ID token to your backend to verify and create/update user
      final response = await http.post(
        Uri.parse("$baseUrl/auth/google"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idToken": idToken,
          "email": googleUser.email,
          "displayName": googleUser.displayName,
        }),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Google sign-in error: $e');
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Check if user is already signed in
  Future<GoogleSignInAccount?> getSignedInUser() async {
    return await _googleSignIn.signInSilently();
  }

  // Get current Google sign-in state
  bool get isGoogleSignedIn => _googleSignIn.currentUser != null;
}
