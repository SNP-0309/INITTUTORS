// lib/features/dashboard/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((_) => DashboardRepository());

final ownerDashboardProvider =
    FutureProvider.autoDispose<DashboardData>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getOwnerDashboard();
});
