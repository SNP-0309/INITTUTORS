// lib/features/announcements/ui/announcements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../data/announcement_models.dart';
import '../providers/announcements_provider.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(announcementsProvider);

    return Scaffold(
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => ref.refresh(announcementsProvider.future),
        child: async.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const SkeletonBox(height: 100, radius: 12),
          ),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (list) {
            if (list.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined,
                        size: 56, color: AppTheme.outlineVariant),
                    SizedBox(height: 12),
                    Text('No announcements yet',
                        style: TextStyle(color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _AnnouncementCard(a: list[i]),
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

class _AnnouncementCard extends StatelessWidget {
  final Announcement a;
  const _AnnouncementCard({required this.a});

  Color get _categoryColor {
    switch (a.category) {
      case 'holiday':      return const Color(0xFF1565C0);
      case 'exam':         return const Color(0xFF6A1B9A);
      case 'fee_reminder': return AppTheme.error;
      default:             return AppTheme.primary;
    }
  }

  IconData get _categoryIcon {
    switch (a.category) {
      case 'holiday':      return Icons.beach_access_rounded;
      case 'exam':         return Icons.school_rounded;
      case 'fee_reminder': return Icons.receipt_long_rounded;
      default:             return Icons.campaign_rounded;
    }
  }

  String get _categoryLabel {
    switch (a.category) {
      case 'holiday':      return 'Holiday';
      case 'exam':         return 'Exam';
      case 'fee_reminder': return 'Fee Reminder';
      default:             return 'General';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = _categoryColor;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainer),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Top accent bar
          if (a.isPinned)
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + priority row
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(children: [
                        Icon(_categoryIcon, size: 12, color: color),
                        const SizedBox(width: 4),
                        Text(_categoryLabel,
                            style: tt.labelSmall
                                ?.copyWith(color: color, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    if (a.isPinned) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryFixed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(children: [
                          const Icon(Icons.push_pin_rounded,
                              size: 12, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text('Pinned',
                              style: tt.labelSmall
                                  ?.copyWith(color: AppTheme.primary)),
                        ]),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _priorityLabel(a.priority),
                      style: tt.labelSmall?.copyWith(
                          color: _priorityColor(a.priority),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Title
                Text(a.title,
                    style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                // Body preview
                Text(a.body,
                    style: tt.bodyMedium
                        ?.copyWith(color: AppTheme.onSurfaceVariant),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                // Footer
                Row(
                  children: [
                    Text(
                      DateFormat('d MMM yyyy, h:mm a').format(a.createdAt.toLocal()),
                      style: tt.labelSmall
                          ?.copyWith(color: AppTheme.onSurfaceVariant),
                    ),
                    if (a.createdByName != null) ...[
                      Text(' • ',
                          style: tt.labelSmall
                              ?.copyWith(color: AppTheme.outlineVariant)),
                      Text(a.createdByName!,
                          style: tt.labelSmall
                              ?.copyWith(color: AppTheme.onSurfaceVariant)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _priorityLabel(String p) {
    switch (p) {
      case 'high':   return '⬆ High';
      case 'urgent': return '🔴 Urgent';
      case 'low':    return '⬇ Low';
      default:       return 'Normal';
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'urgent': return AppTheme.error;
      case 'high':   return AppTheme.warningAmber;
      default:       return AppTheme.onSurfaceVariant;
    }
  }
}
