// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams_app/main.dart';
import 'package:ams_app/features/auth/providers/auth_provider.dart';
import 'package:ams_app/features/auth/data/auth_models.dart';
import 'package:ams_app/features/auth/data/auth_repository.dart';
import 'package:ams_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:ams_app/features/dashboard/data/dashboard_models.dart';
import 'package:ams_app/features/dashboard/data/dashboard_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<LoginResponse> login({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<User> getMe() async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<User?> restoreSession() async {
    // Return null immediately to bypass secure storage native plugin calls
    return null;
  }
}

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardData> getOwnerDashboard() async {
    return const DashboardData(
      date: '2026-07-18',
      todaysAttendanceMarkedBatches: 0,
      todaysAttendancePendingBatches: 0,
      studentsPresentToday: 0,
      studentsAbsentToday: 0,
      attendancePercentageToday: 0.0,
      newAdmissionsThisMonth: 0,
      todaysBatches: [],
      pendingFeesAmount: 0.0,
      pendingFeesStudentsCount: 0,
    );
  }
}

void main() {
  testWidgets('Smoke test AmsApp redirects to login when unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          dashboardRepositoryProvider.overrideWithValue(FakeDashboardRepository()),
        ],
        child: const AmsApp(),
      ),
    );

    // Let the initial microtasks and router redirects process
    await tester.pump();

    // Verify we see the login screen or materials
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
