// lib/features/auth/data/auth_models.dart
import '../../../core/constants/role_constants.dart';

class User {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final UserRole role;
  final String status;

  const User({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    required this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id:     json['id'] as String,
        name:   json['name'] as String,
        email:  json['email'] as String?,
        phone:  json['phone'] as String? ?? '',
        role:   UserRoleX.fromString(json['role'] as String? ?? 'student'),
        status: json['status'] as String? ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id':     id,
        'name':   name,
        'email':  email,
        'phone':  phone,
        'role':   role.value,
        'status': status,
      };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final User user;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken:  json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn:    json['expires_in'] as int? ?? 900,
        user:         User.fromJson(json['user'] as Map<String, dynamic>),
      );
}
