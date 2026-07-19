// lib/features/attendance/providers/attendance_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/role_constants.dart';
import '../data/attendance_models.dart';
import '../data/attendance_repository.dart';

final attendanceRepositoryProvider =
    Provider<AttendanceRepository>((_) => AttendanceRepository());

// ─── Marking state ────────────────────────────────────────────────────────────
class AttendanceMarkingState {
  final List<RosterStudent> roster;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String date;
  final String batchId;
  final String batchName;

  const AttendanceMarkingState({
    required this.roster,
    required this.isLoading,
    required this.isSubmitting,
    required this.date,
    required this.batchId,
    required this.batchName,
    this.error,
  });

  int get markedCount => roster.where((s) => s.status != null).length;
  int get totalCount  => roster.length;

  AttendanceMarkingState copyWith({
    List<RosterStudent>? roster,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? date,
  }) => AttendanceMarkingState(
        roster:       roster ?? this.roster,
        isLoading:    isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        date:         date ?? this.date,
        batchId:      batchId,
        batchName:    batchName,
        error:        error,
      );
}

class AttendanceMarkingNotifier
    extends StateNotifier<AttendanceMarkingState> {
  final AttendanceRepository _repo;

  AttendanceMarkingNotifier(
    this._repo, {
    required String batchId,
    required String batchName,
  }) : super(AttendanceMarkingState(
          roster:       [],
          isLoading:    true,
          isSubmitting: false,
          date:         _todayStr(),
          batchId:      batchId,
          batchName:    batchName,
        )) {
    _loadRoster(batchId);
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadRoster(String batchId) async {
    try {
      final roster = await _repo.getBatchRoster(batchId);
      final existing = await _repo.getExistingAttendance(batchId, state.date);
      for (final s in roster) {
        s.status = existing[s.studentId];
      }
      state = state.copyWith(roster: roster, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void markStudent(String studentId, AttendanceStatus status) {
    final updated = state.roster.map((s) {
      if (s.studentId == studentId) s.status = status;
      return s;
    }).toList();
    state = state.copyWith(roster: updated);
  }

  void markAllPresent() {
    final updated = state.roster.map((s) {
      s.status ??= AttendanceStatus.present;
      return s;
    }).toList();
    state = state.copyWith(roster: updated);
  }

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _repo.submitAttendance(
        batchId: state.batchId,
        date:    state.date,
        roster:  state.roster,
      );
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final attendanceMarkingProvider = StateNotifierProvider.autoDispose
    .family<AttendanceMarkingNotifier, AttendanceMarkingState,
        ({String batchId, String batchName})>((ref, args) {
  return AttendanceMarkingNotifier(
    ref.read(attendanceRepositoryProvider),
    batchId:   args.batchId,
    batchName: args.batchName,
  );
});
