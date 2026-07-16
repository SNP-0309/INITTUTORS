/// Route path constants — never hardcode route strings in call sites.
///
/// Mirrors the route map in frontend.md §4.2, grouped by role. Paths only;
/// the mapping to screens lives in `app_router.dart`.
class RoutePaths {
  const RoutePaths._();

  // Bootstrap
  static const String splash = '/';

  // Auth (public)
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  /// Home path for a role name (`admin`/`teacher`/`parent`/`student`).
  static String homeForRole(String role) {
    switch (role) {
      case 'admin':
        return admin;
      case 'teacher':
        return teacher;
      case 'parent':
        return parent;
      case 'student':
        return student;
      default:
        return login;
    }
  }

  // Admin
  static const String admin = '/admin';
  static const String adminStudents = '/admin/students';
  static const String adminStudentDetail = '/admin/students/:id';
  static const String adminStudentNew = '/admin/students/new';
  static const String adminStudentEdit = '/admin/students/:id/edit';
  static const String adminBatches = '/admin/batches';
  static const String adminBatchDetail = '/admin/batches/:id';
  static const String adminBatchNew = '/admin/batches/new';
  static const String adminAttendance = '/admin/attendance';
  static const String adminReports = '/admin/reports';
  static const String adminAnnouncements = '/admin/announcements';
  static const String adminTimetable = '/admin/timetable';
  static const String adminInstitute = '/admin/institute';
  static const String adminInstituteCreate = '/admin/institute/create';
  static const String adminInstituteEdit = '/admin/institute/edit';
  static const String adminTeachers = '/admin/teachers';
  static const String adminTeacherDetail = '/admin/teachers/:id';
  static const String adminTeacherNew = '/admin/teachers/new';
  static const String adminTeacherEdit = '/admin/teachers/:id/edit';

  // Teacher
  static const String teacher = '/teacher';
  static const String teacherAttendance = '/teacher/attendance/:batchId';
  static const String teacherBatches = '/teacher/batches';
  static const String teacherHomework = '/teacher/homework';
  static const String teacherNotes = '/teacher/notes';

  // Parent
  static const String parent = '/parent';
  static const String parentAttendance = '/parent/attendance';
  static const String parentFees = '/parent/fees';

  // Student
  static const String student = '/student';
  static const String studentAttendance = '/student/attendance';
  static const String studentHomework = '/student/homework';
  static const String studentNotes = '/student/notes';
}
