class StudentParent {
  const StudentParent({
    required this.fullName,
    required this.phone,
    required this.relation,
    required this.isPrimary,
  });

  final String fullName;
  final String phone;
  final String relation;
  final bool isPrimary;

  factory StudentParent.fromJson(Map<String, dynamic> json) {
    return StudentParent(
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      relation: json['relation'] as String? ?? 'guardian',
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'relation': relation,
      'is_primary': isPrimary,
    };
  }
}

class Student {
  const Student({
    required this.id,
    required this.rollNumber,
    required this.admissionDate,
    required this.firstName,
    this.lastName,
    this.phone,
    required this.parentPhone,
    this.email,
    this.address,
    this.school,
    required this.standard,
    this.photoUrl,
    required this.status,
    this.statusReason,
    this.primaryParent,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String rollNumber;
  final String admissionDate;
  final String firstName;
  final String? lastName;
  final String? phone;
  final String parentPhone;
  final String? email;
  final String? address;
  final String? school;
  final String standard;
  final String? photoUrl;
  final String status;
  final String? statusReason;
  final StudentParent? primaryParent;
  final String? createdAt;
  final String? updatedAt;

  String get fullName => '$firstName ${lastName ?? ''}'.trim();

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      rollNumber: json['roll_number'] as String? ?? '',
      admissionDate: json['admission_date'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      parentPhone: json['parent_phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      school: json['school'] as String?,
      standard: json['standard'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      status: json['status'] as String? ?? 'active',
      statusReason: json['status_reason'] as String?,
      primaryParent: json['primary_parent'] != null
          ? StudentParent.fromJson(json['primary_parent'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roll_number': rollNumber,
      'admission_date': admissionDate,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'parent_phone': parentPhone,
      'email': email,
      'address': address,
      'school': school,
      'standard': standard,
      'photo_url': photoUrl,
      'status': status,
      'status_reason': statusReason,
      'primary_parent': primaryParent?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
