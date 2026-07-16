import '../../../core/network/api_client.dart';

class DashboardApi {
  DashboardApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getOwnerDashboard() async {
    final res = await _client.dio.get('/dashboard/owner/');
    return res.data['data'] as Map<String, dynamic>;
  }
}
