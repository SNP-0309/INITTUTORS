// lib/features/dashboard/data/dashboard_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'dashboard_models.dart';

class DashboardRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<DashboardData> getOwnerDashboard() async {
    final response = await _dio.get('/dashboard/owner/');
    final data = _dio.extractData(response) as Map<String, dynamic>;
    return DashboardData.fromJson(data);
  }
}
