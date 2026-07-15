import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class TeacherApi {
  TeacherApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> createTeacher(Map<String, dynamic> data) async {
    final res = await _client.dio.post(
      '/teachers/',
      data: data,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTeacher(String id, Map<String, dynamic> data) async {
    final res = await _client.dio.put(
      '/teachers/$id/',
      data: data,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTeacher(String id) async {
    final res = await _client.dio.get('/teachers/$id/');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listTeachers({String? search, int page = 1}) async {
    final Map<String, dynamic> queryParameters = {'page': page};
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    
    final res = await _client.dio.get(
      '/teachers/',
      queryParameters: queryParameters,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteTeacher(String id) async {
    await _client.dio.delete('/teachers/$id/');
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
