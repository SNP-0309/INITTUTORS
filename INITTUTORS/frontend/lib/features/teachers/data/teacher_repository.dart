import '../domain/teacher.dart';
import 'teacher_api.dart';

class TeacherRepository {
  TeacherRepository(this._api);

  final TeacherApi _api;

  Future<Teacher> createTeacher(Map<String, dynamic> data) async {
    final raw = await _api.createTeacher(data);
    return Teacher.fromJson(raw);
  }

  Future<Teacher> updateTeacher(String id, Map<String, dynamic> data) async {
    final raw = await _api.updateTeacher(id, data);
    return Teacher.fromJson(raw);
  }

  Future<Teacher> getTeacher(String id) async {
    final raw = await _api.getTeacher(id);
    return Teacher.fromJson(raw);
  }

  Future<Map<String, dynamic>> listTeachers({String? search, int page = 1}) async {
    final data = await _api.listTeachers(search: search, page: page);
    final results = data['results'] as List<dynamic>;
    final teachers = results.map((e) => Teacher.fromJson(e as Map<String, dynamic>)).toList();
    return {
      'teachers': teachers,
      'count': data['count'] as int,
      'hasMore': data['next'] != null,
    };
  }

  Future<void> deleteTeacher(String id) async {
    await _api.deleteTeacher(id);
  }
}
