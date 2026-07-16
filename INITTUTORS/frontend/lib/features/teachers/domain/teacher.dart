class TeacherUser {
  const TeacherUser({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.status,
  });

  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String status;

  factory TeacherUser.fromJson(Map<String, dynamic> json) {
    return TeacherUser(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'status': status,
    };
  }
}

class Teacher {
  const Teacher({
    required this.id,
    required this.user,
    this.employeeCode,
    this.specialization,
    this.joiningDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final TeacherUser user;
  final String? employeeCode;
  final String? specialization;
  final String? joiningDate;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String,
      user: TeacherUser.fromJson(json['user'] as Map<String, dynamic>),
      employeeCode: json['employee_code'] as String?,
      specialization: json['specialization'] as String?,
      joiningDate: json['joining_date'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'employee_code': employeeCode,
      'specialization': specialization,
      'joining_date': joiningDate,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
