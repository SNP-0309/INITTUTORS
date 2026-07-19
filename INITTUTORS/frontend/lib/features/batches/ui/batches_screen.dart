// lib/features/batches/ui/batches_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../data/batch_models.dart';
import '../providers/batches_provider.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(batchesProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => ref.refresh(batchesProvider.future),
        child: async.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => const SkeletonBox(height: 100, radius: 12),
          ),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (batches) {
            if (batches.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_outlined,
                        size: 56, color: AppTheme.outlineVariant),
                    SizedBox(height: 12),
                    Text('No batches yet',
                        style: TextStyle(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: batches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _BatchCard(batch: batches[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _BatchCard extends ConsumerWidget {
  final Batch batch;
  const _BatchCard({required this.batch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final dayLabels = {
      'monday': 'Mon', 'tuesday': 'Tue', 'wednesday': 'Wed',
      'thursday': 'Thu', 'friday': 'Fri', 'saturday': 'Sat', 'sunday': 'Sun',
    };
    final days = batch.scheduleDays
        .map((d) => dayLabels[d.toLowerCase()] ?? d)
        .join(', ');

    return GestureDetector(
      onTap: () {
        // Navigate to mark attendance
        context.push('/attendance-mark/${batch.id}', extra: batch.name);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceContainer),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(batch.name,
                      style: tt.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 14, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(batch.subject,
                    style: tt.labelLarge
                        ?.copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.schedule_rounded,
                  size: 14, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('${batch.startTime} – ${batch.endTime}',
                  style: tt.bodyMedium
                      ?.copyWith(color: AppTheme.onSurfaceVariant)),
            ]),
            if (batch.teacherName != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 14, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(batch.teacherName!,
                    style: tt.labelLarge
                        ?.copyWith(color: AppTheme.onSurfaceVariant)),
              ]),
            ],
            if (days.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: batch.scheduleDays.map((d) {
                  final label = dayLabels[d.toLowerCase()] ?? d;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryFixed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(label,
                        style: tt.labelSmall?.copyWith(color: AppTheme.primary)),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.push('/attendance-mark/${batch.id}', extra: batch.name),
                icon: const Icon(Icons.fact_check_rounded, size: 16),
                label: const Text('Mark Attendance'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primaryContainer),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
