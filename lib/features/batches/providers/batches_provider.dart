import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/batch_model.dart';

class BatchesNotifier extends StateNotifier<List<Batch>> {
  BatchesNotifier() : super([]) {
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    final box = await Hive.openBox<Batch>('batches');
    final batches = box.values.toList();
    state = batches.map((b) {
      // One-time migration: if initialStock was never set, seed from chickenCount
      if (b.initialStock == 0 && b.chickenCount > 0) {
        final updated = b.copyWith(initialStock: b.chickenCount);
        box.put(updated.id, updated);
        return updated;
      }
      return b;
    }).toList();
  }

  Future<void> addBatch(Batch batch) async {
    final box = await Hive.openBox<Batch>('batches');
    await box.put(batch.id, batch);
    state = [...state, batch];
  }

  Future<void> updateBatch(Batch batch) async {
    final box = await Hive.openBox<Batch>('batches');
    await box.put(batch.id, batch);
    state = state.map((b) => b.id == batch.id ? batch : b).toList();
  }

  Future<void> deleteBatch(String batchId) async {
    final box = await Hive.openBox<Batch>('batches');
    await box.delete(batchId);
    state = state.where((b) => b.id != batchId).toList();
  }

  Future<void> getBatchesByUserId(String userId) async {
    final box = await Hive.openBox<Batch>('batches');
    state = box.values.where((b) => b.userId == userId).toList();
  }
}

final batchesProvider =
    StateNotifierProvider<BatchesNotifier, List<Batch>>((ref) {
  return BatchesNotifier();
});