// lib/features/attendance/data/attendance_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/role_constants.dart';
import 'attendance_models.dart';

class AttendanceRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<RosterStudent>> getBatchRoster(String batchId) async {
    final response = await _dio.get('/attendance/batch/$batchId/roster/');
    final data = _dio.extractData(response) as Map<String, dynamic>;
    final list = data['roster'] as List<dynamic>? ?? [];
    return list.map((e) => RosterStudent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, AttendanceStatus>> getExistingAttendance(
      String batchId, String date) async {
    try {
      final response = await _dio.get(
        '/attendance/',
        queryParameters: {'batch_id': batchId, 'date': date},
      );
      final data = _dio.extractData(response) as Map<String, dynamic>;
      final records = data['records'] as List<dynamic>? ?? [];
      final result = <String, AttendanceStatus>{};
      for (final r in records) {
        final rec = AttendanceRecord.fromJson(r as Map<String, dynamic>);
        result[rec.studentId] = rec.status;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> submitAttendance({
    required String batchId,
    required String date,
    required List<RosterStudent> roster,
  }) async {
    final records = roster
        .where((s) => s.status != null)
        .map((s) => {
              'student_id': s.studentId,
              'status':     s.status!.value,
            })
        .toList();

    await _dio.post('/attendance/', data: {
      'batch_id': batchId,
      'date':     date,
      'records':  records,
    });
  }
}
