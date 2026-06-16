import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../models/batch_model.dart';
import '../providers/batches_provider.dart';

class BatchStats {
  final int currentStock;
  final int cashInHandCents;
  final int outstandingCreditCents;
  final int cashSaleCount;
  final int creditSaleCount;

  const BatchStats({
    required this.currentStock,
    required this.cashInHandCents,
    required this.outstandingCreditCents,
    required this.cashSaleCount,
    required this.creditSaleCount,
  });
}

BatchStats computeStats(Batch batch, List<TransactionModel> transactions) {
  final txs = transactions.where((t) => t.batchId == batch.id).toList();

  int stock = batch.initialStock;
  int cash = 0;
  int outstanding = 0;
  int cashSaleCount = 0;
  int creditSaleCount = 0;

  for (final t in txs) {
    switch (t.type) {
      case 'sale':
        stock -= t.quantity ?? 0;
        cash += t.amountCents;
        cashSaleCount++;
        break;
      case 'credit_sale':
        stock -= t.quantity ?? 0;
        outstanding += t.amountCents;
        creditSaleCount++;
        break;
      case 'credit_payment':
        outstanding -= t.amountCents;
        cash += t.amountCents;
        break;
      case 'withdrawal':
      case 'expense':
        cash -= t.amountCents;
        break;
    }
  }

  return BatchStats(
    currentStock: stock.clamp(0, 1 << 31),
    cashInHandCents: cash,
    outstandingCreditCents: outstanding.clamp(0, 1 << 31),
    cashSaleCount: cashSaleCount,
    creditSaleCount: creditSaleCount,
  );
}

// Per-batch provider — pass batchId, get live stats
final batchStatsProvider = Provider.family<BatchStats, String>((ref, batchId) {
  final batches = ref.watch(batchesProvider);
  final transactions = ref.watch(transactionsProvider);

  final batch = batches.firstWhere(
    (b) => b.id == batchId,
    orElse: () => throw Exception('Batch not found'),
  );

  return computeStats(batch, transactions);
});