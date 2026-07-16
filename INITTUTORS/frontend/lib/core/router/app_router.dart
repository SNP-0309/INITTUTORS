import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/institutes/presentation/screens/institute_create_screen.dart';
import '../../features/institutes/presentation/screens/institute_profile_screen.dart';
import '../../features/institutes/presentation/screens/institute_edit_screen.dart';
import '../../features/teachers/presentation/screens/teacher_list_screen.dart';
import '../../features/teachers/presentation/screens/teacher_detail_screen.dart';
import '../../features/teachers/presentation/screens/teacher_create_screen.dart';
import '../../features/teachers/presentation/screens/teacher_edit_screen.dart';
import '../../features/students/presentation/screens/student_list_screen.dart';
import '../../features/students/presentation/screens/student_detail_screen.dart';
import '../../features/students/presentation/screens/student_create_screen.dart';
import '../../features/students/presentation/screens/student_edit_screen.dart';
import '../../features/batches/presentation/screens/batch_list_screen.dart';
import '../../features/batches/presentation/screens/batch_detail_screen.dart';
import '../../features/batches/presentation/screens/batch_create_screen.dart';
import '../../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'placeholder_screen.dart';
import 'route_paths.dart';


/// Application router (go_router), configured with the full route map from
/// frontend.md §4.2 plus the auth guard strategy from §4.1.
///
/// Only the auth screens (splash + login) have real UI; role destinations are
/// [PlaceholderScreen] stubs for later modules. The router is a Riverpod
/// provider so it re-evaluates its redirect whenever auth state changes.
final routerProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod auth-state changes to GoRouter's refresh mechanism.
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final onSplash = location == RoutePaths.splash;
      final onAuthScreen =
          location == RoutePaths.login || location == RoutePaths.forgotPassword;

      switch (auth.status) {
        case AuthStatus.unknown:
          // Wait on the splash while bootstrap runs.
          return onSplash ? null : RoutePaths.splash;
        case AuthStatus.unauthenticated:
          return onAuthScreen ? null : RoutePaths.login;
        case AuthStatus.authenticated:
          // Bounce away from splash/login into the role's home.
          if (onSplash || onAuthScreen) {
            return RoutePaths.homeForRole(auth.user?.role.name ?? '');
          }
          return null;
      }
    },
    routes: <RouteBase>[
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) =>
            const PlaceholderScreen('Forgot Password'),
      ),

      // --- Admin ---
      GoRoute(
        path: RoutePaths.admin,
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      GoRoute(
        path: RoutePaths.adminStudents,
        builder: (context, state) => const StudentListScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminStudentNew,
        builder: (context, state) => const StudentCreateScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminStudentDetail,
        builder: (context, state) => StudentDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.adminStudentEdit,
        builder: (context, state) => const StudentEditScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminBatches,
        builder: (context, state) => const BatchListScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminBatchNew,
        builder: (context, state) => const BatchCreateScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminBatchDetail,
        builder: (context, state) => BatchDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.adminAttendance,
        builder: (context, state) =>
            const PlaceholderScreen('Attendance Overview'),
      ),
      GoRoute(
        path: RoutePaths.adminReports,
        builder: (context, state) => const PlaceholderScreen('Reports'),
      ),
      GoRoute(
        path: RoutePaths.adminAnnouncements,
        builder: (context, state) => const PlaceholderScreen('Announcements'),
      ),
      GoRoute(
        path: RoutePaths.adminTimetable,
        builder: (context, state) => const PlaceholderScreen('Timetable'),
      ),
      GoRoute(
        path: RoutePaths.adminInstitute,
        builder: (context, state) => const InstituteProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminInstituteCreate,
        builder: (context, state) => const InstituteCreateScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminInstituteEdit,
        builder: (context, state) => const InstituteEditScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminTeachers,
        builder: (context, state) => const TeacherListScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminTeacherNew,
        builder: (context, state) => const TeacherCreateScreen(),
      ),
      GoRoute(
        path: RoutePaths.adminTeacherDetail,
        builder: (context, state) => TeacherDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.adminTeacherEdit,
        builder: (context, state) => const TeacherEditScreen(),
      ),

      // --- Teacher ---
      GoRoute(
        path: RoutePaths.teacher,
        builder: (context, state) =>
            const PlaceholderScreen('Teacher Dashboard', showLogout: true),
      ),
      GoRoute(
        path: RoutePaths.teacherAttendance,
        builder: (context, state) => const PlaceholderScreen('Mark Attendance'),
      ),
      GoRoute(
        path: RoutePaths.teacherBatches,
        builder: (context, state) => const PlaceholderScreen('My Batches'),
      ),
      GoRoute(
        path: RoutePaths.teacherHomework,
        builder: (context, state) => const PlaceholderScreen('Homework'),
      ),
      GoRoute(
        path: RoutePaths.teacherNotes,
        builder: (context, state) => const PlaceholderScreen('Notes'),
      ),

      // --- Parent ---
      GoRoute(
        path: RoutePaths.parent,
        builder: (context, state) =>
            const PlaceholderScreen('Parent Dashboard', showLogout: true),
      ),
      GoRoute(
        path: RoutePaths.parentAttendance,
        builder: (context, state) =>
            const PlaceholderScreen("Child's Attendance"),
      ),
      GoRoute(
        path: RoutePaths.parentFees,
        builder: (context, state) => const PlaceholderScreen('Fees'),
      ),

      // --- Student ---
      GoRoute(
        path: RoutePaths.student,
        builder: (context, state) =>
            const PlaceholderScreen('Student Dashboard', showLogout: true),
      ),
      GoRoute(
        path: RoutePaths.studentAttendance,
        builder: (context, state) => const PlaceholderScreen('My Attendance'),
      ),
      GoRoute(
        path: RoutePaths.studentHomework,
        builder: (context, state) => const PlaceholderScreen('Homework'),
      ),
      GoRoute(
        path: RoutePaths.studentNotes,
        builder: (context, state) => const PlaceholderScreen('Notes'),
      ),
    ],
    errorBuilder: (context, state) => const PlaceholderScreen('404 Not Found'),
  );
});
