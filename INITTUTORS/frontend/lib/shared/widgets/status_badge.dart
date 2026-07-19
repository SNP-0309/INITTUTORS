// lib/shared/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../../core/constants/role_constants.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: cfg.border),
      ),
      child: Text(
        cfg.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cfg.text),
      ),
    );
  }

  _BadgeConfig _config(String s) {
    switch (s.toLowerCase()) {
      case 'active':
        return _BadgeConfig(
          label: 'Active',
          bg: const Color(0xFFD1FAE5),
          text: const Color(0xFF065F46),
          border: const Color(0xFF6EE7B7),
        );
      case 'left':
      case 'left_coaching':
      case 'inactive':
        return _BadgeConfig(
          label: s == 'inactive' ? 'Inactive' : 'Left',
          bg: AppTheme.surfaceContainerHighest,
          text: AppTheme.onSurfaceVariant,
          border: AppTheme.outlineVariant,
        );
      case 'suspended':
        return _BadgeConfig(
          label: 'Suspended',
          bg: const Color(0xFFFEF3C7),
          text: const Color(0xFF92400E),
          border: const Color(0xFFFCD34D),
        );
      default:
        return _BadgeConfig(
          label: s,
          bg: AppTheme.surfaceContainer,
          text: AppTheme.onSurfaceVariant,
          border: AppTheme.outlineVariant,
        );
    }
  }
}

class AttendanceBadge extends StatelessWidget {
  final AttendanceStatus status;
  const AttendanceBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text, border;
    switch (status) {
      case AttendanceStatus.present:
        bg = const Color(0xFFD1FAE5); text = const Color(0xFF065F46); border = const Color(0xFF6EE7B7);
      case AttendanceStatus.absent:
        bg = AppTheme.errorContainer; text = AppTheme.onErrorContainer; border = AppTheme.error;
      case AttendanceStatus.late:
        bg = const Color(0xFFFEF3C7); text = const Color(0xFF92400E); border = const Color(0xFFFCD34D);
      case AttendanceStatus.leave:
        bg = const Color(0xFFDBEAFE); text = const Color(0xFF1E40AF); border = const Color(0xFF93C5FD);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: border),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: text, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BadgeConfig {
  final String label;
  final Color bg, text, border;
  const _BadgeConfig({required this.label, required this.bg, required this.text, required this.border});
}
