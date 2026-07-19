// lib/features/students/data/student_models.dart

class Student {
  final String id;
  final String firstName;
  final String? lastName;
  final String rollNumber;
  final String standard;
  final String? phone;
  final String parentPhone;
  final String? email;
  final String? photoUrl;
  final String status;
  final String? school;
  final String? address;
  final String admissionDate;

  const Student({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.rollNumber,
    required this.standard,
    this.phone,
    required this.parentPhone,
    this.email,
    this.photoUrl,
    required this.status,
    this.school,
    this.address,
    required this.admissionDate,
  });

  String get fullName =>
      lastName != null && lastName!.isNotEmpty ? '$firstName $lastName' : firstName;

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        id:            j['id'] as String,
        firstName:     j['first_name'] as String,
        lastName:      j['last_name'] as String?,
        rollNumber:    j['roll_number'] as String,
        standard:      j['standard'] as String,
        phone:         j['phone'] as String?,
        parentPhone:   j['parent_phone'] as String? ?? '',
        email:         j['email'] as String?,
        photoUrl:      j['photo_url'] as String?,
        status:        j['status'] as String? ?? 'active',
        school:        j['school'] as String?,
        address:       j['address'] as String?,
        admissionDate: j['admission_date'] as String? ?? '',
      );
}

class PaginatedStudents {
  final int count;
  final String? next;
  final String? previous;
  final List<Student> results;

  const PaginatedStudents({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedStudents.fromJson(Map<String, dynamic> j) => PaginatedStudents(
        count:    j['count'] as int? ?? 0,
        next:     j['next'] as String?,
        previous: j['previous'] as String?,
        results:  (j['results'] as List<dynamic>? ?? [])
            .map((e) => Student.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
