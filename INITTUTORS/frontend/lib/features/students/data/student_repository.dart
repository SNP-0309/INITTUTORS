// lib/features/students/data/student_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'student_models.dart';

class StudentRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<PaginatedStudents> getStudents({int page = 1, String? search}) async {
    final response = await _dio.get('/students/', queryParameters: {
      'page': page,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final data = _dio.extractData(response);
    if (data is Map<String, dynamic>) {
      return PaginatedStudents.fromJson(data);
    }
    // Handle non-paginated response
    return PaginatedStudents(
      count: (data as List).length,
      results: (data).map((e) => Student.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<Student> getStudent(String id) async {
    final response = await _dio.get('/students/$id/');
    final data = _dio.extractData(response) as Map<String, dynamic>;
    return Student.fromJson(data);
  }

  Future<Student> createStudent(Map<String, dynamic> payload) async {
    final response = await _dio.post('/students/', data: payload);
    final data = _dio.extractData(response) as Map<String, dynamic>;
    return Student.fromJson(data);
  }

  Future<Student> updateStudent(String id, Map<String, dynamic> payload) async {
    final response = await _dio.put('/students/$id/', data: payload);
    final data = _dio.extractData(response) as Map<String, dynamic>;
    return Student.fromJson(data);
  }

  Future<void> deleteStudent(String id) async {
    await _dio.delete('/students/$id/');
  }
}
