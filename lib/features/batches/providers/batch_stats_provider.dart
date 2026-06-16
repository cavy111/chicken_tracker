import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feed/models/feed_model.dart';
import '../../feed/providers/feed_provider.dart';
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
  final int feedCostCents;
  final int withdrawalCents;
  final int discountCents;
  final int totalExpensesCents;
  final int projectedRevenueCents;
  final int projectedProfitCents;

  const BatchStats({
    required this.currentStock,
    required this.cashInHandCents,
    required this.outstandingCreditCents,
    required this.cashSaleCount,
    required this.creditSaleCount,
    required this.feedCostCents,
    required this.withdrawalCents,
    required this.discountCents,
    required this.totalExpensesCents,
    required this.projectedRevenueCents,
    required this.projectedProfitCents,
  });
}

BatchStats computeStats(
  Batch batch,
  List<TransactionModel> transactions,
  List<FeedEntry> feedEntries,
) {
  final txs = transactions.where((t) => t.batchId == batch.id).toList();
  final feeds = feedEntries.where((f) => f.batchId == batch.id).toList();

  int stock = batch.initialStock;
  int cash = 0;
  int outstanding = 0;
  int cashSaleCount = 0;
  int creditSaleCount = 0;
  int grossSales = 0;
  int withdrawal = 0;
  int discount = 0;
  final feedCost = feeds.fold(0, (sum, feed) => sum + feed.feedCostCents);

  for (final t in txs) {
    switch (t.type) {
      case 'sale':
        stock -= t.quantity ?? 0;
        cash += t.amountCents;
        grossSales += t.amountCents + t.discountCents;
        cashSaleCount++;
        break;
      case 'credit_sale':
        stock -= t.quantity ?? 0;
        outstanding += t.amountCents;
        grossSales += t.amountCents + t.discountCents;
        creditSaleCount++;
        break;
      case 'credit_payment':
        outstanding -= t.amountCents;
        cash += t.amountCents;
        break;
      case 'discount':
        discount += t.amountCents;
        break;
      case 'mortality':
        stock -= t.quantity ?? 0;
        break;
      case 'withdrawal':
      case 'expense':
        cash -= t.amountCents;
        withdrawal += t.amountCents;
        break;
    }
  }

  final currentStock = stock.clamp(0, 1 << 31);
  final totalExpenses = batch.stockCostCents + feedCost + withdrawal + discount;
  final projectedRevenue = grossSales + (currentStock * batch.salePriceCents);

  return BatchStats(
    currentStock: currentStock,
    cashInHandCents: cash,
    outstandingCreditCents: outstanding.clamp(0, 1 << 31),
    cashSaleCount: cashSaleCount,
    creditSaleCount: creditSaleCount,
    feedCostCents: feedCost,
    withdrawalCents: withdrawal,
    discountCents: discount,
    totalExpensesCents: totalExpenses,
    projectedRevenueCents: projectedRevenue,
    projectedProfitCents: projectedRevenue - totalExpenses,
  );
}

// Per-batch provider — pass batchId, get live stats
final batchStatsProvider = Provider.family<BatchStats, String>((ref, batchId) {
  final batches = ref.watch(batchesProvider);
  final transactions = ref.watch(transactionsProvider);
  final feedEntries = ref.watch(feedProvider);

  final batch = batches.firstWhere(
    (b) => b.id == batchId,
    orElse: () => throw Exception('Batch not found'),
  );

  return computeStats(batch, transactions, feedEntries);
});
