// lib/features/announcements/data/announcement_models.dart

class Announcement {
  final String id;
  final String title;
  final String body;
  final String category;
  final String targetRole;
  final String priority;
  final bool isPinned;
  final String? attachmentUrl;
  final String? createdByName;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.targetRole,
    required this.priority,
    required this.isPinned,
    this.attachmentUrl,
    this.createdByName,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> j) => Announcement(
        id:             j['id'] as String,
        title:          j['title'] as String,
        body:           j['body'] as String,
        category:       j['category'] as String? ?? 'general',
        targetRole:     j['target_role'] as String? ?? 'all',
        priority:       j['priority'] as String? ?? 'normal',
        isPinned:       j['is_pinned'] as bool? ?? false,
        attachmentUrl:  j['attachment_url'] as String?,
        createdByName:  (j['created_by'] as Map<String, dynamic>?)?['name'] as String?,
        createdAt:      DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
