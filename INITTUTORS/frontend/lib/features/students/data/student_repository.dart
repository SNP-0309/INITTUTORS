import '../domain/student.dart';
import 'student_api.dart';

class StudentRepository {
  StudentRepository(this._api);

  final StudentApi _api;

  Future<Student> createStudent(Map<String, dynamic> data) async {
    final raw = await _api.createStudent(data);
    return Student.fromJson(raw);
  }

  Future<Student> updateStudent(String id, Map<String, dynamic> data) async {
    final raw = await _api.updateStudent(id, data);
    return Student.fromJson(raw);
  }

  Future<Student> getStudent(String id) async {
    final raw = await _api.getStudent(id);
    return Student.fromJson(raw);
  }

  Future<Map<String, dynamic>> listStudents({String? search, int page = 1}) async {
    final data = await _api.listStudents(search: search, page: page);
    final results = data['results'] as List<dynamic>;
    final students = results.map((e) => Student.fromJson(e as Map<String, dynamic>)).toList();
    return {
      'students': students,
      'count': data['count'] as int,
      'hasMore': data['next'] != null,
    };
  }

  Future<void> deleteStudent(String id) async {
    await _api.deleteStudent(id);
  }

  Future<String> uploadPhoto(String filePath) async {
    return _api.uploadPhoto(filePath);
  }
}
