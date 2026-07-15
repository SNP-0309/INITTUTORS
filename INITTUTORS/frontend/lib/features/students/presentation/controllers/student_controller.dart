import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/student_api.dart';
import '../../domain/student.dart';
import '../../domain/student_state.dart';

class StudentController extends Notifier<StudentState> {
  @override
  StudentState build() => const StudentState.initial();

  String _currentSearch = '';

  Future<void> loadStudents({String? search, bool isRefresh = false}) async {
    final searchStr = search ?? _currentSearch;
    final isNewSearch = searchStr != _currentSearch;
    
    if (isRefresh || isNewSearch || state.status == StudentLoadStatus.initial) {
      _currentSearch = searchStr;
      state = state.copyWith(
        status: StudentLoadStatus.loading,
        students: [],
        currentPage: 1,
        hasMore: false,
        error: null,
      );
    } else {
      if (state.status == StudentLoadStatus.loading || !state.hasMore) return;
      state = state.copyWith(status: StudentLoadStatus.loading);
    }

    try {
      final repo = ref.read(studentRepositoryProvider);
      final result = await repo.listStudents(
        search: _currentSearch,
        page: state.currentPage,
      );
      
      final List<Student> loadedStudents = result['students'] as List<Student>;
      final int count = result['count'] as int;
      final bool hasMore = result['hasMore'] as bool;

      state = state.copyWith(
        status: StudentLoadStatus.loaded,
        students: isRefresh || isNewSearch
            ? loadedStudents
            : [...state.students, ...loadedStudents],
        count: count,
        currentPage: state.currentPage + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudentLoadStatus.error,
        error: StudentApi.messageFrom(e, 'Failed to load students.'),
      );
    }
  }

  Future<void> loadStudentDetails(String id) async {
    state = state.copyWith(status: StudentLoadStatus.loading, error: null);
    try {
      final repo = ref.read(studentRepositoryProvider);
      final details = await repo.getStudent(id);
      state = state.copyWith(
        status: StudentLoadStatus.loaded,
        student: details,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudentLoadStatus.error,
        error: StudentApi.messageFrom(e, 'Failed to load student details.'),
      );
    }
  }

  Future<void> createStudent(Map<String, dynamic> data) async {
    state = state.copyWith(status: StudentLoadStatus.loading, error: null);
    try {
      final repo = ref.read(studentRepositoryProvider);
      final created = await repo.createStudent(data);
      state = state.copyWith(
        status: StudentLoadStatus.loaded,
        students: [created, ...state.students],
        student: created,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudentLoadStatus.error,
        error: StudentApi.messageFrom(e, 'Failed to create student.'),
      );
      rethrow;
    }
  }

  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: StudentLoadStatus.loading, error: null);
    try {
      final repo = ref.read(studentRepositoryProvider);
      final updated = await repo.updateStudent(id, data);
      
      final newList = state.students.map((s) => s.id == id ? updated : s).toList();
      state = state.copyWith(
        status: StudentLoadStatus.loaded,
        students: newList,
        student: updated,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudentLoadStatus.error,
        error: StudentApi.messageFrom(e, 'Failed to update student.'),
      );
      rethrow;
    }
  }

  Future<void> deleteStudent(String id) async {
    state = state.copyWith(status: StudentLoadStatus.loading, error: null);
    try {
      final repo = ref.read(studentRepositoryProvider);
      await repo.deleteStudent(id);
      
      final newList = state.students.where((s) => s.id != id).toList();
      state = state.copyWith(
        status: StudentLoadStatus.loaded,
        students: newList,
        student: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: StudentLoadStatus.error,
        error: StudentApi.messageFrom(e, 'Failed to delete student.'),
      );
      rethrow;
    }
  }

  Future<String> uploadPhoto(String filePath) async {
    try {
      final repo = ref.read(studentRepositoryProvider);
      return await repo.uploadPhoto(filePath);
    } catch (e) {
      throw Exception(StudentApi.messageFrom(e, 'Failed to upload photo.'));
    }
  }
}

final studentControllerProvider =
    NotifierProvider<StudentController, StudentState>(StudentController.new);
