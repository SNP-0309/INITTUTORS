import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/batch_api.dart';
import '../../domain/batch.dart';
import '../../domain/batch_state.dart';

class BatchController extends Notifier<BatchState> {
  @override
  BatchState build() => const BatchState.initial();

  String _currentSearch = '';

  Future<void> loadBatches({String? search, bool isRefresh = false}) async {
    final searchStr = search ?? _currentSearch;
    final isNewSearch = searchStr != _currentSearch;

    if (isRefresh || isNewSearch || state.status == BatchLoadStatus.initial) {
      _currentSearch = searchStr;
      state = state.copyWith(
        status: BatchLoadStatus.loading,
        batches: [],
        currentPage: 1,
        hasMore: false,
        error: null,
      );
    } else {
      if (state.status == BatchLoadStatus.loading || !state.hasMore) return;
      state = state.copyWith(status: BatchLoadStatus.loading);
    }

    try {
      final repo = ref.read(batchRepositoryProvider);
      final result = await repo.listBatches(
        search: _currentSearch,
        page: state.currentPage,
      );

      final List<Batch> loadedBatches = result['batches'] as List<Batch>;
      final int count = result['count'] as int;
      final bool hasMore = result['hasMore'] as bool;

      state = state.copyWith(
        status: BatchLoadStatus.loaded,
        batches: isRefresh || isNewSearch
            ? loadedBatches
            : [...state.batches, ...loadedBatches],
        count: count,
        currentPage: state.currentPage + 1,
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        status: BatchLoadStatus.error,
        error: BatchApi.messageFrom(e, 'Failed to load batches.'),
      );
    }
  }

  Future<void> loadBatchDetails(String id) async {
    state = state.copyWith(status: BatchLoadStatus.loading, error: null);
    try {
      final repo = ref.read(batchRepositoryProvider);
      final details = await repo.getBatch(id);
      state = state.copyWith(
        status: BatchLoadStatus.loaded,
        batch: details['batch'] as Batch,
        roster: details['roster'] as List<BatchStudent>,
      );
    } catch (e) {
      state = state.copyWith(
        status: BatchLoadStatus.error,
        error: BatchApi.messageFrom(e, 'Failed to load batch details.'),
      );
    }
  }

  Future<void> loadSubjectsAndClassrooms() async {
    try {
      final repo = ref.read(batchRepositoryProvider);
      final subjects = await repo.listSubjects();
      final classrooms = await repo.listClassrooms();
      state = state.copyWith(
        subjects: subjects,
        classrooms: classrooms,
      );
    } catch (e) {
      // Ignored or handle silently
    }
  }

  Future<void> createBatch(Map<String, dynamic> data) async {
    state = state.copyWith(status: BatchLoadStatus.loading, error: null);
    try {
      final repo = ref.read(batchRepositoryProvider);
      final created = await repo.createBatch(data);
      state = state.copyWith(
        status: BatchLoadStatus.loaded,
        batches: [created, ...state.batches],
        batch: created,
      );
    } catch (e) {
      state = state.copyWith(
        status: BatchLoadStatus.error,
        error: BatchApi.messageFrom(e, 'Failed to create batch.'),
      );
      rethrow;
    }
  }

  Future<void> updateBatch(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: BatchLoadStatus.loading, error: null);
    try {
      final repo = ref.read(batchRepositoryProvider);
      final updated = await repo.updateBatch(id, data);
      final newList = state.batches.map((b) => b.id == id ? updated : b).toList();
      state = state.copyWith(
        status: BatchLoadStatus.loaded,
        batches: newList,
        batch: updated,
      );
    } catch (e) {
      state = state.copyWith(
        status: BatchLoadStatus.error,
        error: BatchApi.messageFrom(e, 'Failed to update batch.'),
      );
      rethrow;
    }
  }

  Future<void> deleteBatch(String id) async {
    state = state.copyWith(status: BatchLoadStatus.loading, error: null);
    try {
      final repo = ref.read(batchRepositoryProvider);
      await repo.deleteBatch(id);
      final newList = state.batches.where((b) => b.id != id).toList();
      state = state.copyWith(
        status: BatchLoadStatus.loaded,
        batches: newList,
        batch: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: BatchLoadStatus.error,
        error: BatchApi.messageFrom(e, 'Failed to delete batch.'),
      );
      rethrow;
    }
  }

  Future<void> assignStudent(String studentId) async {
    final currentBatch = state.batch;
    if (currentBatch == null) return;
    state = state.copyWith(status: BatchLoadStatus.loading, error: null);
    try {
      final repo = ref.read(batchRepositoryProvider);
      await repo.assignStudent(currentBatch.id, studentId);
      // Reload details to get fresh roster & capacity counts
      await loadBatchDetails(currentBatch.id);
    } catch (e) {
      state = state.copyWith(
        status: BatchLoadStatus.loaded, // Reset load status
        error: BatchApi.messageFrom(e, 'Failed to assign student.'),
      );
      rethrow;
    }
  }

  Future<void> removeStudent(String studentId) async {
    final currentBatch = state.batch;
    if (currentBatch == null) return;
    state = state.copyWith(status: BatchLoadStatus.loading, error: null);
    try {
      final repo = ref.read(batchRepositoryProvider);
      await repo.removeStudent(currentBatch.id, studentId);
      // Reload details
      await loadBatchDetails(currentBatch.id);
    } catch (e) {
      state = state.copyWith(
        status: BatchLoadStatus.loaded,
        error: BatchApi.messageFrom(e, 'Failed to remove student.'),
      );
      rethrow;
    }
  }
}

final batchControllerProvider =
    NotifierProvider<BatchController, BatchState>(BatchController.new);
