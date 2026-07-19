// lib/shared/widgets/stat_card.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? subtitle;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceContainer),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4, offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelLarge?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: tt.headlineLarge?.copyWith(
                    fontSize: 24,
                    color: valueColor ?? AppTheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: tt.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
