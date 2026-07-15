import '../config/env.dart';

/// API endpoint constants.
///
/// The backend is versioned under `/api/v1` (api.md §2). Feature-specific
/// paths are added here as endpoints are implemented — none are defined during
/// initialization.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String apiPrefix = '/api/v1';

  static String get baseUrl => '${Env.apiBaseUrl}$apiPrefix';

  static const String institutes = '/institutes/';

  static const String teachers = '/teachers/';

  static const String students = '/students/';

  static const String mediaUpload = '/media/upload/';

  static const String batches = '/batches/';

  static const String subjects = '/batches/subjects/';

  static const String classrooms = '/batches/classrooms/';
}
