import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

/// Application router (go_router), configured with the full route map from
/// frontend.md §4.2.
///
/// This is routing *configuration* only. Every route currently resolves to a
/// [_PlaceholderScreen] stub — no real UI is implemented yet. Role-based guards
/// (frontend.md §4.1) will be wired via `redirect` once auth state exists; the
/// hook is left as a documented TODO rather than implemented here.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.login,
    // TODO(auth): add `redirect:` here to enforce ProtectedRoute role guards
    // (frontend.md §4.1) once the auth store is implemented.
    routes: <RouteBase>[
      // --- Auth (public) ---
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const _PlaceholderScreen('Login'),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const _PlaceholderScreen('Forgot Password'),
      ),

      // --- Admin ---
      GoRoute(
        path: RoutePaths.admin,
        builder: (context, state) => const _PlaceholderScreen('Admin Dashboard'),
      ),
      GoRoute(
        path: RoutePaths.adminStudents,
        builder: (context, state) => const _PlaceholderScreen('Students'),
      ),
      GoRoute(
        path: RoutePaths.adminBatches,
        builder: (context, state) => const _PlaceholderScreen('Batches'),
      ),
      GoRoute(
        path: RoutePaths.adminAttendance,
        builder: (context, state) =>
            const _PlaceholderScreen('Attendance Overview'),
      ),
      GoRoute(
        path: RoutePaths.adminReports,
        builder: (context, state) => const _PlaceholderScreen('Reports'),
      ),
      GoRoute(
        path: RoutePaths.adminAnnouncements,
        builder: (context, state) => const _PlaceholderScreen('Announcements'),
      ),
      GoRoute(
        path: RoutePaths.adminTimetable,
        builder: (context, state) => const _PlaceholderScreen('Timetable'),
      ),

      // --- Teacher ---
      GoRoute(
        path: RoutePaths.teacher,
        builder: (context, state) => const _PlaceholderScreen('Teacher Dashboard'),
      ),
      GoRoute(
        path: RoutePaths.teacherAttendance,
        builder: (context, state) => const _PlaceholderScreen('Mark Attendance'),
      ),
      GoRoute(
        path: RoutePaths.teacherBatches,
        builder: (context, state) => const _PlaceholderScreen('My Batches'),
      ),
      GoRoute(
        path: RoutePaths.teacherHomework,
        builder: (context, state) => const _PlaceholderScreen('Homework'),
      ),
      GoRoute(
        path: RoutePaths.teacherNotes,
        builder: (context, state) => const _PlaceholderScreen('Notes'),
      ),

      // --- Parent ---
      GoRoute(
        path: RoutePaths.parent,
        builder: (context, state) => const _PlaceholderScreen('Parent Dashboard'),
      ),
      GoRoute(
        path: RoutePaths.parentAttendance,
        builder: (context, state) =>
            const _PlaceholderScreen("Child's Attendance"),
      ),
      GoRoute(
        path: RoutePaths.parentFees,
        builder: (context, state) => const _PlaceholderScreen('Fees'),
      ),

      // --- Student ---
      GoRoute(
        path: RoutePaths.student,
        builder: (context, state) => const _PlaceholderScreen('Student Dashboard'),
      ),
      GoRoute(
        path: RoutePaths.studentAttendance,
        builder: (context, state) => const _PlaceholderScreen('My Attendance'),
      ),
      GoRoute(
        path: RoutePaths.studentHomework,
        builder: (context, state) => const _PlaceholderScreen('Homework'),
      ),
      GoRoute(
        path: RoutePaths.studentNotes,
        builder: (context, state) => const _PlaceholderScreen('Notes'),
      ),
    ],
    errorBuilder: (context, state) => const _PlaceholderScreen('404 Not Found'),
  );
}

/// Temporary stand-in for not-yet-implemented screens. Replaced per-route as
/// real UI is built in later phases.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$label — not implemented')),
    );
  }
}
