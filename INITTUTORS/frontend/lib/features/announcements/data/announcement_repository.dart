// lib/features/announcements/data/announcement_repository.dart
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'announcement_models.dart';

class AnnouncementRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Announcement>> getAnnouncements() async {
    final response = await _dio.get('/announcements/');
    final data = _dio.extractData(response);
    if (data is List) {
      return data.map((e) => Announcement.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data.containsKey('results')) {
      return (data['results'] as List)
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
