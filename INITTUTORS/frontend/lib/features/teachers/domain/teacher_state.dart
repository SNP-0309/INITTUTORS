import 'teacher.dart';

enum TeacherLoadStatus { initial, loading, loaded, error }

class TeacherState {
  const TeacherState({
    required this.status,
    this.teachers = const [],
    this.teacher,
    this.count = 0,
    this.currentPage = 1,
    this.hasMore = false,
    this.error,
  });

  final TeacherLoadStatus status;
  final List<Teacher> teachers;
  final Teacher? teacher;
  final int count;
  final int currentPage;
  final bool hasMore;
  final String? error;

  const TeacherState.initial() : this(status: TeacherLoadStatus.initial);

  TeacherState copyWith({
    TeacherLoadStatus? status,
    List<Teacher>? teachers,
    Teacher? teacher,
    int? count,
    int? currentPage,
    bool? hasMore,
    String? error,
  }) {
    return TeacherState(
      status: status ?? this.status,
      teachers: teachers ?? this.teachers,
      teacher: teacher ?? this.teacher,
      count: count ?? this.count,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}
