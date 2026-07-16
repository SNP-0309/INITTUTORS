import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/token_storage.dart';
import '../../features/institutes/data/institute_api.dart';
import '../../features/institutes/data/institute_repository.dart';
import '../../features/teachers/data/teacher_api.dart';
import '../../features/teachers/data/teacher_repository.dart';
import '../../features/students/data/student_api.dart';
import '../../features/students/data/student_repository.dart';
import '../../features/batches/data/batch_api.dart';
import '../../features/batches/data/batch_repository.dart';

/// Global Riverpod providers (app-wide singletons + dependency wiring).
///
/// State management is Riverpod (the Flutter equivalent of frontend.md's
/// TanStack Query + Zustand split). Feature controllers live in their
/// `features/<domain>/presentation` folders.

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// The shared, configured HTTP client (attaches JWT, refreshes on 401).
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.read(tokenStorageProvider)),
);

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.read(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.read(authApiProvider),
    ref.read(tokenStorageProvider),
  ),
);

final instituteApiProvider = Provider<InstituteApi>(
  (ref) => InstituteApi(ref.read(apiClientProvider)),
);

final instituteRepositoryProvider = Provider<InstituteRepository>(
  (ref) => InstituteRepository(ref.read(instituteApiProvider)),
);

final teacherApiProvider = Provider<TeacherApi>(
  (ref) => TeacherApi(ref.read(apiClientProvider)),
);

final teacherRepositoryProvider = Provider<TeacherRepository>(
  (ref) => TeacherRepository(ref.read(teacherApiProvider)),
);

final studentApiProvider = Provider<StudentApi>(
  (ref) => StudentApi(ref.read(apiClientProvider)),
);

final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepository(ref.read(studentApiProvider)),
);

final batchApiProvider = Provider<BatchApi>(
  (ref) => BatchApi(ref.read(apiClientProvider)),
);

final batchRepositoryProvider = Provider<BatchRepository>(
  (ref) => BatchRepository(ref.read(batchApiProvider)),
);
