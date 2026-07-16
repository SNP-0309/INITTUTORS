import '../../../shared/constants/app_constants.dart';

/// The authenticated user, mirroring the backend `/auth/me` + login payload
/// (api.md §3.4). `instituteId` is null — multi-tenancy is out of scope.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.status,
    this.instituteId,
  });

  final String id;
  final String name;
  final Role role;
  final String? email;
  final String? phone;
  final String? status;
  final String? instituteId;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      role: _roleFromString(json['role'] as String?),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      instituteId: json['institute_id'] as String?,
    );
  }

  static Role _roleFromString(String? value) {
    return Role.values.firstWhere(
      (r) => r.name == value,
      orElse: () => Role.student,
    );
  }
}
