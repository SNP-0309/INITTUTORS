// lib/core/constants/role_constants.dart

enum UserRole { admin, teacher, student, parent }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:   return 'admin';
      case UserRole.teacher: return 'teacher';
      case UserRole.student: return 'student';
      case UserRole.parent:  return 'parent';
    }
  }

  static UserRole fromString(String v) {
    switch (v) {
      case 'admin':   return UserRole.admin;
      case 'teacher': return UserRole.teacher;
      case 'student': return UserRole.student;
      case 'parent':  return UserRole.parent;
      default:        return UserRole.student;
    }
  }
}

enum AttendanceStatus { present, absent, late, leave }

extension AttendanceStatusX on AttendanceStatus {
  String get value {
    switch (this) {
      case AttendanceStatus.present: return 'present';
      case AttendanceStatus.absent:  return 'absent';
      case AttendanceStatus.late:    return 'late';
      case AttendanceStatus.leave:   return 'leave';
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present: return 'P';
      case AttendanceStatus.absent:  return 'A';
      case AttendanceStatus.late:    return 'L';
      case AttendanceStatus.leave:   return 'LV';
    }
  }

  static AttendanceStatus fromString(String v) {
    switch (v) {
      case 'present': return AttendanceStatus.present;
      case 'absent':  return AttendanceStatus.absent;
      case 'late':    return AttendanceStatus.late;
      case 'leave':   return AttendanceStatus.leave;
      default:        return AttendanceStatus.absent;
    }
  }
}
