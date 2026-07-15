import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/teacher_api.dart';
import '../../domain/teacher.dart';
import '../../domain/teacher_state.dart';

class TeacherController extends Notifier<TeacherState> {
  @override
  TeacherState build() => const TeacherState.initial();

  String _currentSearch = '';

  Future<void> loadTeachers({String? search, bool isRefresh = false}) async {
    final searchStr = search ?? _currentSearch;
    final isNewSearch = searchStr != _currentSearch;
    
    if (isRefresh || isNewSearch || state.status == TeacherLoadStatus.initial) {
      _currentSearch = searchStr;
      state = state.copyWith(
        status: TeacherLoadStatus.loading,
        teachers: [],
        currentPage: 1,
        hasMore: false,
        error: null,
      );
    } else {
      if (state.status == TeacherLoadStatus.loading || !state.hasMore) return;
      state = state.copyWith(status: TeacherLoadStatus.loading);
    }

    try {
      final repo = ref.read(teacherRepositoryProvider);
      final result = await repo.listTeachers(
        search: _currentSearch,
        page: state.currentPage,
      );
      
      final List<Teacher> loadedTeachers = result['teachers'] as List<Teacher>;
      final int count = result['count'] as int;
      final bool hasMore = result['hasMore'] as bool;

      state = state.copyWith(
        status: TeacherLoadStatus.loaded,
        teachers: isRefresh || isNewSearch
            ? loadedTeachers
            : [...state.teachers, ...loadedTeachers],
        count: count,
        currentPage: state.currentPage + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        status: TeacherLoadStatus.error,
        error: TeacherApi.messageFrom(e, 'Failed to load teachers.'),
      );
    }
  }

  Future<void> loadTeacherDetails(String id) async {
    state = state.copyWith(status: TeacherLoadStatus.loading, error: null);
    try {
      final repo = ref.read(teacherRepositoryProvider);
      final details = await repo.getTeacher(id);
      state = state.copyWith(
        status: TeacherLoadStatus.loaded,
        teacher: details,
      );
    } catch (e) {
      state = state.copyWith(
        status: TeacherLoadStatus.error,
        error: TeacherApi.messageFrom(e, 'Failed to load teacher details.'),
      );
    }
  }

  Future<void> createTeacher(Map<String, dynamic> data) async {
    state = state.copyWith(status: TeacherLoadStatus.loading, error: null);
    try {
      final repo = ref.read(teacherRepositoryProvider);
      final created = await repo.createTeacher(data);
      state = state.copyWith(
        status: TeacherLoadStatus.loaded,
        teachers: [created, ...state.teachers],
        teacher: created,
      );
    } catch (e) {
      state = state.copyWith(
        status: TeacherLoadStatus.error,
        error: TeacherApi.messageFrom(e, 'Failed to create teacher.'),
      );
      rethrow;
    }
  }

  Future<void> updateTeacher(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: TeacherLoadStatus.loading, error: null);
    try {
      final repo = ref.read(teacherRepositoryProvider);
      final updated = await repo.updateTeacher(id, data);
      
      final newList = state.teachers.map((t) => t.id == id ? updated : t).toList();
      state = state.copyWith(
        status: TeacherLoadStatus.loaded,
        teachers: newList,
        teacher: updated,
      );
    } catch (e) {
      state = state.copyWith(
        status: TeacherLoadStatus.error,
        error: TeacherApi.messageFrom(e, 'Failed to update teacher.'),
      );
      rethrow;
    }
  }

  Future<void> deleteTeacher(String id) async {
    state = state.copyWith(status: TeacherLoadStatus.loading, error: null);
    try {
      final repo = ref.read(teacherRepositoryProvider);
      await repo.deleteTeacher(id);
      
      final newList = state.teachers.where((t) => t.id != id).toList();
      state = state.copyWith(
        status: TeacherLoadStatus.loaded,
        teachers: newList,
        teacher: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TeacherLoadStatus.error,
        error: TeacherApi.messageFrom(e, 'Failed to delete teacher.'),
      );
      rethrow;
    }
  }
}

final teacherControllerProvider =
    NotifierProvider<TeacherController, TeacherState>(TeacherController.new);
