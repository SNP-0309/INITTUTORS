// lib/features/batches/data/batch_models.dart

class Batch {
  final String id;
  final String name;
  final String subject;
  final String? teacherName;
  final String? teacherId;
  final String? standard;
  final String startTime;
  final String endTime;
  final List<String> scheduleDays;
  final int studentCount;
  final String status;

  const Batch({
    required this.id,
    required this.name,
    required this.subject,
    this.teacherName,
    this.teacherId,
    this.standard,
    required this.startTime,
    required this.endTime,
    required this.scheduleDays,
    required this.studentCount,
    required this.status,
  });

  factory Batch.fromJson(Map<String, dynamic> j) => Batch(
        id:           j['id'] as String,
        name:         j['name'] as String,
        subject:      (j['subject'] as Map<String, dynamic>?)?['name'] as String? ?? j['subject_name'] as String? ?? '',
        teacherName:  (j['teacher'] as Map<String, dynamic>?)?['name'] as String?,
        teacherId:    (j['teacher'] as Map<String, dynamic>?)?['id'] as String?,
        standard:     j['standard'] as String?,
        startTime:    j['start_time'] as String,
        endTime:      j['end_time'] as String,
        scheduleDays: (j['schedule_days'] as List<dynamic>? ?? []).cast<String>(),
        studentCount: j['student_count'] as int? ?? 0,
        status:       j['status'] as String? ?? 'active',
      );
}
