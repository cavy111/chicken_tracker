import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/batch_model.dart';
import '../../transactions/models/transaction_model.dart';

class BatchesNotifier extends StateNotifier<List<Batch>> {
  BatchesNotifier() : super([]) {
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    final box = await Hive.openBox<Batch>('batches');
    // Migrate legacy batches created before initialStock/currentStock existed,
    // falling back to chickenCount which was the original stock field.
    final batches = box.values.toList();
    state = batches.map((b) {
      final initialStock = b.initialStock > 0 ? b.initialStock : b.chickenCount;
      final currentStock =
          b.currentStock > 0 ? b.currentStock : initialStock;
      if (initialStock != b.initialStock || currentStock != b.currentStock) {
        final updated =
            b.copyWith(initialStock: initialStock, currentStock: currentStock);
        box.put(updated.id, updated);
        return updated;
      }
      return b;
    }).toList();
  }

  Future<void> addBatch(Batch batch) async {
    final box = await Hive.openBox<Batch>('batches');
    // Ensure currentStock is set to initialStock if not explicitly set
    final batchToSave = batch.currentStock == 0 ? batch.copyWith(currentStock: batch.initialStock) : batch;
    await box.put(batchToSave.id, batchToSave);
    state = [...state, batchToSave];
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
    state = box.values.where((batch) => batch.userId == userId).toList();
  }

  // Apply a transaction to update batch fields
  Future<void> applyTransaction(TransactionModel t) async {
    final box = await Hive.openBox<Batch>('batches');
    final b = box.get(t.batchId);
    if (b == null) return;

    int newStock = b.currentStock;
    int newCash = b.cashInHandCents;
    int newOutstanding = b.outstandingCreditCents;

    switch (t.type) {
      case 'sale':
        newStock = (newStock - (t.quantity ?? 0)).clamp(0, 1 << 31);
        newCash = newCash + t.amountCents;
        break;
      case 'credit_sale':
        newStock = (newStock - (t.quantity ?? 0)).clamp(0, 1 << 31);
        newOutstanding = newOutstanding + t.amountCents;
        break;
      case 'credit_payment':
        newOutstanding = (newOutstanding - t.amountCents).clamp(0, 1 << 31);
        newCash = newCash + t.amountCents;
        break;
      case 'withdrawal':
        newCash = (newCash - t.amountCents).clamp(-1 << 31, 1 << 31);
        break;
      case 'expense':
        newCash = (newCash - t.amountCents).clamp(-1 << 31, 1 << 31);
        break;
      default:
        break;
    }

    final updated = b.copyWith(
      currentStock: newStock,
      cashInHandCents: newCash,
      outstandingCreditCents: newOutstanding,
      updatedAt: DateTime.now(),
    );
    await box.put(updated.id, updated);

    state = state.map((x) => x.id == updated.id ? updated : x).toList();
  }
}

final batchesProvider =
    StateNotifierProvider<BatchesNotifier, List<Batch>>((ref) {
  return BatchesNotifier();
});