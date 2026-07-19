// lib/features/batches/providers/batches_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/batch_models.dart';
import '../data/batch_repository.dart';

final batchRepositoryProvider =
    Provider<BatchRepository>((_) => BatchRepository());

final batchesProvider = FutureProvider.autoDispose<List<Batch>>((ref) {
  return ref.read(batchRepositoryProvider).getBatches();
});

final batchDetailProvider =
    FutureProvider.autoDispose.family<Batch, String>((ref, id) {
  return ref.read(batchRepositoryProvider).getBatch(id);
});
