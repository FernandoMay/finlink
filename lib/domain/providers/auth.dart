import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }
  
  // Sign up with email and phone verification
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String nationalId,
    String? biometricHash,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Create user account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Create user profile in Firestore
        await _createUserProfile(
          uid: result.user!.uid,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          nationalId: nationalId,
          biometricHash: biometricHash,
        );
        
        // Send email verification
        await result.user!.sendEmailVerification();
        
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign in with email/password
  Future<bool> signIn({
    required String email,
    required String password,
    String? biometricHash,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Verify biometric if provided
        if (biometricHash != null) {
          bool biometricValid = await _verifyBiometric(
            result.user!.uid,
            biometricHash,
          );
          if (!biometricValid) {
            await signOut();
            _setError('Verificación biométrica fallida');
            return false;
          }
        }
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Error inesperado: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Phone verification for secure transactions
  Future<String?> verifyPhoneNumber(String phoneNumber) async {
    try {
      _setLoading(true);
      String? verificationId;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _auth.currentUser?.linkWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(_getErrorMessage(e.code));
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: Duration(seconds: 60),
      );
      
      return verificationId;
    } catch (e) {
      _setError('Error en verificación telefónica: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update biometric hash
  Future<bool> updateBiometric(String biometricData) async {
    try {
      if (_user == null) return false;
      
      String biometricHash = _hashBiometric(biometricData);
      
      await _firestore.collection('users').doc(_user!.uid).update({
        'biometricHash': biometricHash,
        'biometricUpdatedAt': FieldValue.serverTimestamp(),
      });
      
      await _loadUserProfile();
      return true;
    } catch (e) {
      _setError('Error actualizando biométrica: ${e.toString()}');
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _userProfile = null;
    } catch (e) {
      _setError('Error cerrando sesión: ${e.toString()}');
    }
  }
  
  // Password reset
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Private methods
  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    required String phoneNumber,
    required String nationalId,
    String? biometricHash,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'nationalId': _hashSensitiveData(nationalId),
      'biometricHash': biometricHash,
      'walletBalance': 0.0,
      'creditScore': 0,
      'isVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'financialGoals': [],
      'preferences': {
        'currency': 'USD',
        'language': 'es',
        'notifications': true,
      },
    });
  }
  
  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .get();
      
      if (doc.exists) {
        _userProfile = doc.data() as Map<String, dynamic>?;
        
        // Update last login
        await _firestore.collection('users').doc(_user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _setError('Error cargando perfil: ${e.toString()}');
    }
  }
  
  Future<bool> _verifyBiometric(String uid, String biometricHash) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['biometricHash'] == biometricHash;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  String _hashBiometric(String biometricData) {
    var bytes = utf8.encode('${biometricData}finlink_salt');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  String _hashSensitiveData(String data) {
    var bytes = utf8.encode('${data}finlink_security_salt');
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación: $code';
    }
  }
}