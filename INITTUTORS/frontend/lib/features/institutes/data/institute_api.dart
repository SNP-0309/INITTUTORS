import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class InstituteApi {
  InstituteApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> createInstitute(Map<String, dynamic> data) async {
    final res = await _client.dio.post(
      '/institutes/',
      data: data,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateInstitute(String id, Map<String, dynamic> data) async {
    final res = await _client.dio.put(
      '/institutes/$id/',
      data: data,
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getInstitute(String id) async {
    final res = await _client.dio.get('/institutes/$id/');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> listInstitutes() async {
    final res = await _client.dio.get('/institutes/');
    return res.data['data'] as List<dynamic>;
  }

  static String messageFrom(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] is Map) {
        final msg = data['error']['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
    }
    return fallback;
  }
}
