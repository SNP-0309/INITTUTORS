import '../domain/batch.dart';
import 'batch_api.dart';

class BatchRepository {
  BatchRepository(this._api);

  final BatchApi _api;

  Future<Batch> createBatch(Map<String, dynamic> data) async {
    final raw = await _api.createBatch(data);
    return Batch.fromJson(raw);
  }

  Future<Batch> updateBatch(String id, Map<String, dynamic> data) async {
    final raw = await _api.updateBatch(id, data);
    return Batch.fromJson(raw);
  }

  Future<Map<String, dynamic>> getBatch(String id) async {
    final data = await _api.getBatch(id);
    final batchRaw = data['batch'] as Map<String, dynamic>;
    final rosterRaw = data['roster'] as List<dynamic>;
    
    final batch = Batch.fromJson(batchRaw);
    final roster = rosterRaw.map((e) => BatchStudent.fromJson(e as Map<String, dynamic>)).toList();
    
    return {
      'batch': batch,
      'roster': roster,
    };
  }

  Future<Map<String, dynamic>> listBatches({String? search, int page = 1}) async {
    final data = await _api.listBatches(search: search, page: page);
    final results = data['results'] as List<dynamic>;
    final batches = results.map((e) => Batch.fromJson(e as Map<String, dynamic>)).toList();
    return {
      'batches': batches,
      'count': data['count'] as int,
      'hasMore': data['next'] != null,
    };
  }

  Future<void> deleteBatch(String id) async {
    await _api.deleteBatch(id);
  }

  Future<void> assignStudent(String batchId, String studentId) async {
    await _api.assignStudent(batchId, studentId);
  }

  Future<void> removeStudent(String batchId, String studentId) async {
    await _api.removeStudent(batchId, studentId);
  }

  Future<List<Subject>> listSubjects() async {
    final raw = await _api.listSubjects();
    return raw.map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Classroom>> listClassrooms() async {
    final raw = await _api.listClassrooms();
    return raw.map((e) => Classroom.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Subject> createSubject(Map<String, dynamic> data) async {
    final raw = await _api.createSubject(data);
    return Subject.fromJson(raw);
  }

  Future<Classroom> createClassroom(Map<String, dynamic> data) async {
    final raw = await _api.createClassroom(data);
    return Classroom.fromJson(raw);
  }
}
