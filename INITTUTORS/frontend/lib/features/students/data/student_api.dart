import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class StudentApi {
  StudentApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> data) async {
    final res = await _client.dio.post(
      '/students/',
      data: data,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateStudent(String id, Map<String, dynamic> data) async {
    final res = await _client.dio.put(
      '/students/$id/',
      data: data,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudent(String id) async {
    final res = await _client.dio.get('/students/$id/');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listStudents({String? search, int page = 1}) async {
    final Map<String, dynamic> queryParameters = {'page': page};
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    
    final res = await _client.dio.get(
      '/students/',
      queryParameters: queryParameters,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteStudent(String id) async {
    await _client.dio.delete('/students/$id/');
  }

  Future<String> uploadPhoto(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _client.dio.post(
      '/media/upload/',
      data: formData,
    );
    return res.data['data']['url'] as String;
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
