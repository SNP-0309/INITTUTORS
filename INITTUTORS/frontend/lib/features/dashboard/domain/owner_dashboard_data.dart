class OwnerDashboardData {
  const OwnerDashboardData({
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

  final String date;
  final int todaysAttendanceMarkedBatches;
  final int todaysAttendancePendingBatches;
  final int studentsPresentToday;
  final int studentsAbsentToday;
  final double attendancePercentageToday;
  final int newAdmissionsThisMonth;
  final List<TodaysBatch> todaysBatches;
  final int pendingFeesAmount;
  final int pendingFeesStudentsCount;

  factory OwnerDashboardData.fromJson(Map<String, dynamic> json) {
    return OwnerDashboardData(
      date: json['date'] as String,
      todaysAttendanceMarkedBatches: json['todays_attendance_marked_batches'] as int,
      todaysAttendancePendingBatches: json['todays_attendance_pending_batches'] as int,
      studentsPresentToday: json['students_present_today'] as int,
      studentsAbsentToday: json['students_absent_today'] as int,
      attendancePercentageToday: (json['attendance_percentage_today'] as num).toDouble(),
      newAdmissionsThisMonth: json['new_admissions_this_month'] as int,
      todaysBatches: (json['todays_batches'] as List<dynamic>)
          .map((e) => TodaysBatch.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingFeesAmount: json['pending_fees_amount'] as int,
      pendingFeesStudentsCount: json['pending_fees_students_count'] as int,
    );
  }
}

class TodaysBatch {
  const TodaysBatch({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.standard,
    required this.studentCount,
  });

  final String id;
  final String name;
  final String subjectName;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String standard;
  final int studentCount;

  factory TodaysBatch.fromJson(Map<String, dynamic> json) {
    return TodaysBatch(
      id: json['id'] as String,
      name: json['name'] as String,
      subjectName: json['subject_name'] as String,
      teacherName: json['teacher_name'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      standard: json['standard'] as String? ?? '',
      studentCount: json['student_count'] as int,
    );
  }
}
