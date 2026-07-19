// lib/features/attendance/ui/attendance_marking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/role_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../data/attendance_models.dart';
import '../providers/attendance_provider.dart';

class AttendanceMarkingScreen extends ConsumerWidget {
  final String batchId;
  final String batchName;

  const AttendanceMarkingScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (batchId: batchId, batchName: batchName);
    final markingState = ref.watch(attendanceMarkingProvider(args));
    final notifier     = ref.read(attendanceMarkingProvider(args).notifier);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      body: Stack(
        children: [
          // ── Fixed Header ─────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                color: AppTheme.surfaceContainerLowest,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.surfaceContainer,
                            shape: const CircleBorder(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Mark Attendance',
                            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Context row
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.menu_book_rounded,
                                    size: 14, color: AppTheme.primary),
                                const SizedBox(width: 4),
                                Text(batchName,
                                    style: tt.labelLarge
                                        ?.copyWith(color: AppTheme.primary)),
                              ]),
                              const SizedBox(height: 2),
                              Row(children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 14, color: AppTheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(markingState.date,
                                    style: tt.labelSmall?.copyWith(
                                        color: AppTheme.onSurfaceVariant)),
                              ]),
                            ],
                          ),
                          // Marked counter pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryFixed.withAlpha(80),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                  color: AppTheme.primaryContainer.withAlpha(80)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.fact_check_rounded,
                                  size: 14, color: AppTheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Marked: ${markingState.markedCount}/${markingState.totalCount}',
                                style: tt.labelLarge
                                    ?.copyWith(color: AppTheme.primary),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable Roster ────────────────────────────────────────
          Positioned.fill(
            top: 150,
            bottom: 80,
            child: markingState.isLoading
                ? ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: 8,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, __) => const _RosterSkeleton(),
                  )
                : markingState.roster.isEmpty
                    ? const Center(child: Text('No students in this batch'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: markingState.roster.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _StudentRow(
                          student: markingState.roster[i],
                          onMark: (status) => notifier.markStudent(
                              markingState.roster[i].studentId, status),
                        ),
                      ),
          ),

          // ── Fixed Footer ─────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                color: AppTheme.surfaceContainerLowest,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    // Mark All Present
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => notifier.markAllPresent(),
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: const Text('Mark All Present'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Submit
                    Expanded(
                      child: ElevatedButton(
                        onPressed: markingState.isSubmitting
                            ? null
                            : () async {
                                final ok = await notifier.submit();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(ok
                                          ? '✓ Attendance saved!'
                                          : markingState.error ?? 'Failed'),
                                      backgroundColor: ok
                                          ? AppTheme.successGreen
                                          : AppTheme.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  if (ok) Navigator.of(context).pop();
                                }
                              },
                        child: markingState.isSubmitting
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.onPrimary))
                            : const Text('Submit Attendance'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final RosterStudent student;
  final void Function(AttendanceStatus) onMark;

  const _StudentRow({required this.student, required this.onMark});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainer),
        boxShadow: const [
          BoxShadow(color: Color(0x07000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          AppAvatar(photoUrl: student.photoUrl, name: student.name, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    style: tt.labelLarge
                        ?.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('ID: ${student.rollNumber}',
                    style: tt.labelSmall
                        ?.copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          // P / A / L toggle buttons
          Row(
            children: [
              _ToggleBtn(label: 'P',
                selected: student.status == AttendanceStatus.present,
                selectedBg: AppTheme.primary,
                onTap: () => onMark(AttendanceStatus.present)),
              const SizedBox(width: 6),
              _ToggleBtn(label: 'A',
                selected: student.status == AttendanceStatus.absent,
                selectedBg: AppTheme.error,
                onTap: () => onMark(AttendanceStatus.absent)),
              const SizedBox(width: 6),
              _ToggleBtn(label: 'L',
                selected: student.status == AttendanceStatus.late,
                selectedBg: AppTheme.tertiary,
                onTap: () => onMark(AttendanceStatus.late)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedBg;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.selected,
      required this.selectedBg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: 36, height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? selectedBg : AppTheme.surface,
          border: Border.all(
            color: selected ? selectedBg : AppTheme.outlineVariant,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: selectedBg.withAlpha(80),
                  blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _RosterSkeleton extends StatelessWidget {
  const _RosterSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainer),
      ),
      child: Row(
        children: const [
          SkeletonBox(width: 42, height: 42, radius: 21),
          SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(height: 12, width: 120),
              SizedBox(height: 6),
              SkeletonBox(height: 10, width: 60),
            ],
          )),
          SizedBox(width: 12),
          SkeletonBox(width: 36, height: 36, radius: 18),
          SizedBox(width: 6),
          SkeletonBox(width: 36, height: 36, radius: 18),
          SizedBox(width: 6),
          SkeletonBox(width: 36, height: 36, radius: 18),
        ],
      ),
    );
  }
}
