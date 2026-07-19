// lib/features/dashboard/ui/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../providers/dashboard_provider.dart';
import '../data/dashboard_models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(ownerDashboardProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => ref.refresh(ownerDashboardProvider.future),
        child: dashAsync.when(
          loading: () => const _DashboardSkeleton(),
          error: (e, _) => _ErrorState(message: e.toString()),
          data: (data) => _DashboardBody(data: data),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardData data;
  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.compact(locale: 'en_IN');
    final tt = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date ──────────────────────────────────────────────────
                Text(
                  'Today, ${DateFormat('d MMMM yyyy').format(DateTime.now())}',
                  style: tt.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),

                // ── Stats grid ────────────────────────────────────────────
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.45,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      label: 'Total Students',
                      value: (data.studentsPresentToday + data.studentsAbsentToday)
                          .toString(),
                    ),
                    StatCard(
                      label: "Today's Attendance",
                      value: '${data.attendancePercentageToday.toStringAsFixed(1)}%',
                      trailing: data.attendancePercentageToday >= 80
                          ? const Icon(Icons.arrow_upward_rounded,
                              size: 16, color: AppTheme.successGreen)
                          : const Icon(Icons.arrow_downward_rounded,
                              size: 16, color: AppTheme.error),
                    ),
                    StatCard(
                      label: 'New Admissions',
                      value: data.newAdmissionsThisMonth.toString(),
                      subtitle: 'This month',
                    ),
                    StatCard(
                      label: 'Pending Fees',
                      value: '₹${currencyFmt.format(data.pendingFeesAmount)}',
                      valueColor: AppTheme.error,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Attendance Overview ───────────────────────────────────
                _SectionCard(
                  title: 'Attendance Overview',
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Marked',
                              style: tt.labelLarge
                                  ?.copyWith(color: AppTheme.onSurfaceVariant)),
                          Text(
                            '${data.studentsPresentToday} / ${data.studentsPresentToday + data.studentsAbsentToday}',
                            style: tt.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: data.attendancePercentageToday / 100,
                          minHeight: 8,
                          backgroundColor: AppTheme.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _PillChip(
                            label: '${data.todaysAttendanceMarkedBatches} Marked',
                            color: AppTheme.successGreen,
                          ),
                          _PillChip(
                            label: '${data.todaysAttendancePendingBatches} Pending',
                            color: AppTheme.warningAmber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Today's Schedule ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Schedule", style: tt.headlineSmall),
                    Text(
                      '${data.todaysBatches.length} batches',
                      style: tt.bodyMedium
                          ?.copyWith(color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (data.todaysBatches.isEmpty)
                  _EmptyState(
                    icon: Icons.event_busy_rounded,
                    message: 'No batches scheduled for today.',
                  )
                else
                  ...data.todaysBatches.map((b) => _BatchCard(batch: b)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainer),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final TodaysBatch batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainer),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(batch.name,
                    style: tt.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${batch.startTime} – ${batch.endTime}',
                        style: tt.bodyMedium
                            ?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(batch.teacherName,
                        style: tt.labelLarge
                            ?.copyWith(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryFixed,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '${batch.studentCount} Students',
              style: tt.labelLarge?.copyWith(color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final Color color;
  const _PillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.outlineVariant),
          const SizedBox(height: 12),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: AppTheme.error),
          const SizedBox(height: 12),
          Text('Failed to load dashboard',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 12, width: 160),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.45,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              StatCardSkeleton(), StatCardSkeleton(),
              StatCardSkeleton(), StatCardSkeleton(),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonBox(height: 120, radius: 12),
          const SizedBox(height: 24),
          const SkeletonBox(height: 14, width: 140),
          const SizedBox(height: 12),
          const SkeletonBox(height: 90, radius: 12),
          const SizedBox(height: 10),
          const SkeletonBox(height: 90, radius: 12),
        ],
      ),
    );
  }
}
