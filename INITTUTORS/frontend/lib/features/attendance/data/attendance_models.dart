// lib/features/attendance/data/attendance_models.dart
import '../../../core/constants/role_constants.dart';

class RosterStudent {
  final String studentId;
  final String name;
  final String rollNumber;
  final String? photoUrl;
  AttendanceStatus? status;

  RosterStudent({
    required this.studentId,
    required this.name,
    required this.rollNumber,
    this.photoUrl,
    this.status,
  });

  factory RosterStudent.fromJson(Map<String, dynamic> j) => RosterStudent(
        studentId:  j['student_id'] as String,
        name:       j['name'] as String,
        rollNumber: j['roll_number'] as String,
        photoUrl:   j['photo_url'] as String?,
      );
}

class AttendanceRecord {
  final String id;
  final String studentId;
  final String date;
  final AttendanceStatus status;
  final String? notes;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
        id:        j['id'] as String,
        studentId: (j['student'] as Map<String, dynamic>?)?['id'] as String? ?? '',
        date:      j['date'] as String,
        status:    AttendanceStatusX.fromString(j['status'] as String? ?? 'absent'),
        notes:     j['notes'] as String?,
      );
}

class AttendanceStats {
  final int total, present, late, absent, leave;
  final double percentage;
  const AttendanceStats({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.leave,
    required this.percentage,
  });
  factory AttendanceStats.fromJson(Map<String, dynamic> j) => AttendanceStats(
        total:      j['total'] as int? ?? 0,
        present:    j['present'] as int? ?? 0,
        late:       j['late'] as int? ?? 0,
        absent:     j['absent'] as int? ?? 0,
        leave:      j['leave'] as int? ?? 0,
        percentage: (j['percentage'] as num?)?.toDouble() ?? 0.0,
      );
}
