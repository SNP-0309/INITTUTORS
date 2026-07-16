import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class BatchApi {
  BatchApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> createBatch(Map<String, dynamic> data) async {
    final res = await _client.dio.post(
      '/batches/',
      data: data,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateBatch(String id, Map<String, dynamic> data) async {
    final res = await _client.dio.put(
      '/batches/$id/',
      data: data,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBatch(String id) async {
    final res = await _client.dio.get('/batches/$id/');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listBatches({String? search, int page = 1}) async {
    final Map<String, dynamic> queryParameters = {'page': page};
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    
    final res = await _client.dio.get(
      '/batches/',
      queryParameters: queryParameters,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteBatch(String id) async {
    await _client.dio.delete('/batches/$id/');
  }

  Future<void> assignStudent(String batchId, String studentId) async {
    await _client.dio.post(
      '/batches/$batchId/assign/',
      data: {'student_id': studentId},
    );
  }

  Future<void> removeStudent(String batchId, String studentId) async {
    await _client.dio.post(
      '/batches/$batchId/remove/',
      data: {'student_id': studentId},
    );
  }

  Future<List<dynamic>> listSubjects() async {
    final res = await _client.dio.get('/batches/subjects/');
    return res.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> listClassrooms() async {
    final res = await _client.dio.get('/batches/classrooms/');
    return res.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createSubject(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/batches/subjects/', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createClassroom(Map<String, dynamic> data) async {
    final res = await _client.dio.post('/batches/classrooms/', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }

  static String messageFrom(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] is Map) {
        final errorData = data['error'];
        if (errorData['details'] is List) {
          final detailsList = errorData['details'] as List;
          if (detailsList.isNotEmpty) {
            final firstDetail = detailsList.first;
            if (firstDetail is Map) {
              final field = firstDetail['field'];
              final issue = firstDetail['issue'];
              return '$field: $issue';
            }
          }
        }
        final msg = errorData['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    }
    return fallback;
  }
}
