// lib/models/user.dart
import 'dart:convert';

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String kycStatus;
  final bool isActive;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.kycStatus = 'pending',
    this.isActive = true,
    this.emailVerified = false,
    this.phoneVerified = false,
    required this.createdAt,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName';

  String get displayName => firstName.isNotEmpty ? firstName : email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'] ?? '',
      phone: json['phone'],
      kycStatus: json['kycStatus'] ?? json['kyc_status'] ?? 'pending',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      emailVerified: json['emailVerified'] ?? json['email_verified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? json['phone_verified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['lastLogin'] != null || json['last_login'] != null
          ? DateTime.parse(json['lastLogin'] ?? json['last_login'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'kycStatus': kycStatus,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}