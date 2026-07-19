// lib/features/announcements/providers/announcements_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/announcement_models.dart';
import '../data/announcement_repository.dart';

final announcementRepositoryProvider =
    Provider<AnnouncementRepository>((_) => AnnouncementRepository());

final announcementsProvider =
    FutureProvider.autoDispose<List<Announcement>>((ref) {
  return ref.read(announcementRepositoryProvider).getAnnouncements();
});
