import '../../teachers/domain/teacher.dart';
import '../../students/domain/student.dart';

class Subject {
  const Subject({required this.id, required this.name});

  final String id;
  final String name;

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Classroom {
  const Classroom({required this.id, required this.name, this.capacity});

  final String id;
  final String name;
  final int? capacity;

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      capacity: json['capacity'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'capacity': capacity};
}

class BatchSchedule {
  const BatchSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  factory BatchSchedule.fromJson(Map<String, dynamic> json) {
    return BatchSchedule(
      id: json['id'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class Batch {
  const Batch({
    required this.id,
    required this.name,
    required this.subject,
    required this.teacher,
    this.classroom,
    this.standard,
    required this.capacity,
    required this.status,
    this.schedules = const [],
  });

  final String id;
  final String name;
  final Subject subject;
  final Teacher teacher;
  final Classroom? classroom;
  final String? standard;
  final int capacity;
  final String status;
  final List<BatchSchedule> schedules;

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      subject: Subject.fromJson(json['subject'] as Map<String, dynamic>),
      teacher: Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
      classroom: json['classroom'] != null
          ? Classroom.fromJson(json['classroom'] as Map<String, dynamic>)
          : null,
      standard: json['standard'] as String?,
      capacity: json['capacity'] as int? ?? 30,
      status: json['status'] as String? ?? 'active',
      schedules: json['schedules'] != null
          ? (json['schedules'] as List<dynamic>)
              .map((e) => BatchSchedule.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject.toJson(),
      'teacher': teacher.toJson(),
      'classroom': classroom?.toJson(),
      'standard': standard,
      'capacity': capacity,
      'status': status,
      'schedules': schedules.map((e) => e.toJson()).toList(),
    };
  }
}

class BatchStudent {
  const BatchStudent({
    required this.id,
    required this.student,
    required this.enrolledOn,
    this.leftOn,
    required this.status,
  });

  final String id;
  final Student student;
  final String enrolledOn;
  final String? leftOn;
  final String status;

  factory BatchStudent.fromJson(Map<String, dynamic> json) {
    return BatchStudent(
      id: json['id'] as String,
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
      enrolledOn: json['enrolled_on'] as String? ?? '',
      leftOn: json['left_on'] as String?,
      status: json['status'] as String? ?? 'active',
    );
  }
}
