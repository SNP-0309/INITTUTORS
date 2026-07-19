// lib/shared/providers/router_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/students/ui/students_screen.dart';
import '../../features/batches/ui/batches_screen.dart';
import '../../features/announcements/ui/announcements_screen.dart';
import '../../features/attendance/ui/attendance_marking_screen.dart';
import '../widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (ctx, state) {
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoading       = authState is AuthInitial || authState is AuthLoading;
      final isLoginRoute    = state.matchedLocation == '/login';

      if (isLoading) return null; // Wait, no redirect
      if (!isAuthenticated && !isLoginRoute) return '/login';
      if (isAuthenticated && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      // ── Auth ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),

      // ── Attendance marking (pushes on top of shell) ───────────────────
      GoRoute(
        path: '/attendance-mark/:batchId',
        builder: (_, state) {
          final batchId   = state.pathParameters['batchId']!;
          final batchName = state.extra as String? ?? 'Batch';
          return AttendanceMarkingScreen(
              batchId: batchId, batchName: batchName);
        },
      ),

      // ── Main shell with bottom navigation ────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, __) => const DashboardScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/students',
              builder: (_, __) => const StudentsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/batches',
              builder: (_, __) => const BatchesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/more',
              builder: (_, __) => const AnnouncementsScreen(),
            ),
          ]),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
