// import 'package:firebase_auth/firebase_auth.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   Future<UserCredential> signInWithEmail(String email, String password) async {
//     return await _auth.signInWithEmailAndPassword(email: email, password: password);
//   }

//   Future<UserCredential> registerWithEmail(String email, String password) async {
//     return await _auth.createUserWithEmailAndPassword(email: email, password: password);
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   User? get currentUser => _auth.currentUser;
// }

// lib/services/auth_service.dart
import 'dart:convert';

import 'package:finlink/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<AuthResult> login(String email, String password) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final userData = response.data!['user'];
      
      await _saveToken(token);
      final user = User.fromJson(userData);
      
      return AuthResult(success: true, user: user);
    }

    return AuthResult(
      success: false, 
      error: response.message ?? 'Login failed'
    );
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final response = await _apiService.post('/auth/register', {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    });

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final userData = response.data!['user'];
      
      await _saveToken(token);
      final user = User.fromJson(userData);
      
      return AuthResult(success: true, user: user);
    }

    return AuthResult(
      success: false, 
      error: response.message ?? 'Registration failed'
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    
    return null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({required this.success, this.user, this.error});
}
