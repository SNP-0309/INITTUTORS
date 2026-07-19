// lib/features/batches/data/batch_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'batch_models.dart';

class BatchRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Batch>> getBatches() async {
    final response = await _dio.get('/batches/');
    final data = _dio.extractData(response);
    if (data is List) {
      return data.map((e) => Batch.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data.containsKey('results')) {
      return (data['results'] as List)
          .map((e) => Batch.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Batch> getBatch(String id) async {
    final response = await _dio.get('/batches/$id/');
    return Batch.fromJson(_dio.extractData(response) as Map<String, dynamic>);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
