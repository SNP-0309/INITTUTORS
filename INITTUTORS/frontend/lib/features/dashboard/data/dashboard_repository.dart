import '../domain/owner_dashboard_data.dart';
import 'dashboard_api.dart';

class DashboardRepository {
  DashboardRepository(this._api);

  final DashboardApi _api;

  Future<OwnerDashboardData> getOwnerDashboard() async {
    final raw = await _api.getOwnerDashboard();
    return OwnerDashboardData.fromJson(raw);
  }
}
