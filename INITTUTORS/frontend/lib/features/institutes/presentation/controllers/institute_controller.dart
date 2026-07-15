import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/institute_api.dart';
import '../../domain/institute.dart';
import '../../domain/institute_state.dart';

class InstituteController extends Notifier<InstituteState> {
  @override
  InstituteState build() => const InstituteState.initial();

  Future<void> loadInstitutes() async {
    state = state.copyWith(status: InstituteLoadStatus.loading, error: null);
    try {
      final repo = ref.read(instituteRepositoryProvider);
      final list = await repo.listInstitutes();
      state = state.copyWith(
        status: InstituteLoadStatus.loaded,
        institutes: list,
        institute: list.isNotEmpty ? list.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        status: InstituteLoadStatus.error,
        error: InstituteApi.messageFrom(e, 'Failed to load institutes.'),
      );
    }
  }

  Future<void> createInstitute(Map<String, dynamic> data) async {
    state = state.copyWith(status: InstituteLoadStatus.loading, error: null);
    try {
      final repo = ref.read(instituteRepositoryProvider);
      final newInst = await repo.createInstitute(data);
      state = state.copyWith(
        status: InstituteLoadStatus.loaded,
        institute: newInst,
        institutes: [...state.institutes, newInst],
      );
    } catch (e) {
      state = state.copyWith(
        status: InstituteLoadStatus.error,
        error: InstituteApi.messageFrom(e, 'Failed to create institute.'),
      );
      rethrow;
    }
  }

  Future<void> updateInstitute(String id, Map<String, dynamic> data) async {
    state = state.copyWith(status: InstituteLoadStatus.loading, error: null);
    try {
      final repo = ref.read(instituteRepositoryProvider);
      final updated = await repo.updateInstitute(id, data);
      
      final newList = state.institutes.map((inst) {
        return inst.id == id ? updated : inst;
      }).toList();

      state = state.copyWith(
        status: InstituteLoadStatus.loaded,
        institute: updated,
        institutes: newList,
      );
    } catch (e) {
      state = state.copyWith(
        status: InstituteLoadStatus.error,
        error: InstituteApi.messageFrom(e, 'Failed to update institute.'),
      );
      rethrow;
    }
  }
}

final instituteControllerProvider =
    NotifierProvider<InstituteController, InstituteState>(InstituteController.new);
