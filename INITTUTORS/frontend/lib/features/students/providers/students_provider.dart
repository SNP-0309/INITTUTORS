// lib/features/students/providers/students_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/student_models.dart';
import '../data/student_repository.dart';

final studentRepositoryProvider =
    Provider<StudentRepository>((_) => StudentRepository());

// Search query state
final studentSearchProvider = StateProvider<String>((_) => '');

// Paginated students list
final studentsProvider = FutureProvider.autoDispose
    .family<PaginatedStudents, ({int page, String search})>((ref, args) {
  final repo = ref.read(studentRepositoryProvider);
  return repo.getStudents(page: args.page, search: args.search.isEmpty ? null : args.search);
});

// Single student detail
final studentDetailProvider =
    FutureProvider.autoDispose.family<Student, String>((ref, id) {
  final repo = ref.read(studentRepositoryProvider);
  return repo.getStudent(id);
});
