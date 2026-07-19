// lib/features/dashboard/data/dashboard_models.dart

class TodaysBatch {
  final String id;
  final String name;
  final String subjectName;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String? standard;
  final int studentCount;

  const TodaysBatch({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    this.standard,
    required this.studentCount,
  });

  factory TodaysBatch.fromJson(Map<String, dynamic> j) => TodaysBatch(
        id:           j['id'] as String,
        name:         j['name'] as String,
        subjectName:  j['subject_name'] as String,
        teacherName:  j['teacher_name'] as String,
        startTime:    j['start_time'] as String,
        endTime:      j['end_time'] as String,
        standard:     j['standard'] as String?,
        studentCount: j['student_count'] as int? ?? 0,
      );
}

class DashboardData {
  final String date;
  final int todaysAttendanceMarkedBatches;
  final int todaysAttendancePendingBatches;
  final int studentsPresentToday;
  final int studentsAbsentToday;
  final double attendancePercentageToday;
  final int newAdmissionsThisMonth;
  final List<TodaysBatch> todaysBatches;
  final double pendingFeesAmount;
  final int pendingFeesStudentsCount;

  const DashboardData({
    required this.date,
    required this.todaysAttendanceMarkedBatches,
    required this.todaysAttendancePendingBatches,
    required this.studentsPresentToday,
    required this.studentsAbsentToday,
    required this.attendancePercentageToday,
    required this.newAdmissionsThisMonth,
    required this.todaysBatches,
    required this.pendingFeesAmount,
    required this.pendingFeesStudentsCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        date:                              j['date'] as String,
        todaysAttendanceMarkedBatches:     j['todays_attendance_marked_batches'] as int? ?? 0,
        todaysAttendancePendingBatches:    j['todays_attendance_pending_batches'] as int? ?? 0,
        studentsPresentToday:              j['students_present_today'] as int? ?? 0,
        studentsAbsentToday:               j['students_absent_today'] as int? ?? 0,
        attendancePercentageToday:         (j['attendance_percentage_today'] as num?)?.toDouble() ?? 0.0,
        newAdmissionsThisMonth:            j['new_admissions_this_month'] as int? ?? 0,
        todaysBatches:                     (j['todays_batches'] as List<dynamic>? ?? [])
            .map((e) => TodaysBatch.fromJson(e as Map<String, dynamic>))
            .toList(),
        pendingFeesAmount:                 (j['pending_fees_amount'] as num?)?.toDouble() ?? 0.0,
        pendingFeesStudentsCount:          j['pending_fees_students_count'] as int? ?? 0,
      );
}
