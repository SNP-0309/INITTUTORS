// Shared client-side enums mirroring the backend value sets (api.md §5,
// database.md §5). Kept in sync with `apps/common/constants.py` so status and
// role strings are never hardcoded (development.md §3.1).

enum Role { admin, teacher, student, parent }

enum StudentStatus { active, left, suspended }

enum AttendanceStatus { present, absent, late, leave }

enum DayOfWeek { mon, tue, wed, thu, fri, sat, sun }

enum AnnouncementType { holiday, exam, feeReminder, general }
