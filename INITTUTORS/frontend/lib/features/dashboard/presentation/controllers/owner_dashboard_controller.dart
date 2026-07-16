import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/app_providers.dart';
import '../../domain/owner_dashboard_data.dart';

final ownerDashboardControllerProvider =
    FutureProvider.autoDispose<OwnerDashboardData>((ref) async {
  return ref.read(dashboardRepositoryProvider).getOwnerDashboard();
});
