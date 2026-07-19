// lib/shared/widgets/app_avatar.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';

class AppAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;

  const AppAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = 48,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _fallback(),
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppTheme.primaryContainer,
        alignment: Alignment.center,
        child: Text(
          _initials,
          style: TextStyle(
            color: AppTheme.onPrimaryContainer,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
