import 'student.dart';

enum StudentLoadStatus { initial, loading, loaded, error }

class StudentState {
  const StudentState({
    required this.status,
    this.students = const [],
    this.student,
    this.count = 0,
    this.currentPage = 1,
    this.hasMore = false,
    this.error,
  });

  final StudentLoadStatus status;
  final List<Student> students;
  final Student? student;
  final int count;
  final int currentPage;
  final bool hasMore;
  final String? error;

  const StudentState.initial() : this(status: StudentLoadStatus.initial);

  StudentState copyWith({
    StudentLoadStatus? status,
    List<Student>? students,
    Student? student,
    int? count,
    int? currentPage,
    bool? hasMore,
    String? error,
  }) {
    return StudentState(
      status: status ?? this.status,
      students: students ?? this.students,
      student: student ?? this.student,
      count: count ?? this.count,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}
