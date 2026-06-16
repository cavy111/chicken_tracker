import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>((ref) {
  return TransactionsNotifier(ref);
});

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  final Ref ref;
  TransactionsNotifier(this.ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    state = box.values.toList();
  }

  Future<void> addTransaction(TransactionModel t) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.put(t.id, t);
    state = [...state, t];
  }

  Future<void> recordSale({
    required String batchId,
    required int quantity,
    required int totalAmountCents,
    required bool isCredit,
    int discountCents = 0,
    int? unitSalePriceCents,
    String? note,
    String? creditorName,
    DateTime? creditDate,
    DateTime? expectedPaymentDate,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final t = TransactionModel(
      id: id,
      batchId: batchId,
      type: isCredit ? 'credit_sale' : 'sale',
      amountCents: totalAmountCents,
      quantity: quantity,
      isCredit: isCredit,
      note: note,
      date: now,
      userId: null,
      createdAt: now,
      updatedAt: now,
      creditorName: creditorName,
      creditDate: isCredit ? (creditDate ?? now) : null,
      expectedPaymentDate: isCredit
          ? (expectedPaymentDate ?? now.add(const Duration(days: 7)))
          : null,
      discountCents: discountCents,
      unitSalePriceCents: unitSalePriceCents,
    );
    await addTransaction(t);
    if (discountCents > 0) {
      await addTransaction(
        TransactionModel(
          id: const Uuid().v4(),
          batchId: batchId,
          type: 'discount',
          amountCents: discountCents,
          quantity: quantity,
          isCredit: false,
          note: note?.isNotEmpty == true ? note : 'Sale discount',
          date: now,
          userId: null,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<void> recordWithdrawal({
    required String batchId,
    required int amountCents,
    String? note,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final t = TransactionModel(
      id: id,
      batchId: batchId,
      type: 'withdrawal',
      amountCents: amountCents,
      quantity: null,
      isCredit: false,
      note: note,
      date: now,
      userId: null,
      createdAt: now,
      updatedAt: now,
    );
    await addTransaction(t);
  }

  Future<void> recordMortality({
    required String batchId,
    required int quantity,
    String? note,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final t = TransactionModel(
      id: id,
      batchId: batchId,
      type: 'mortality',
      amountCents: 0,
      quantity: quantity,
      isCredit: false,
      note: note,
      date: now,
      userId: null,
      createdAt: now,
      updatedAt: now,
    );
    await addTransaction(t);
  }

  Future<void> recordCreditPayment({
    required String batchId,
    required String creditSaleId,
    required int amountCents,
    String? note,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final t = TransactionModel(
      id: id,
      batchId: batchId,
      type: 'credit_payment',
      amountCents: amountCents,
      quantity: null,
      isCredit: false,
      note: note,
      date: now,
      userId: null,
      createdAt: now,
      updatedAt: now,
      linkedCreditSaleId: creditSaleId,
    );
    await addTransaction(t);
  }

  Future<void> updateTransaction(TransactionModel t) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.put(t.id, t);
    state = state.map((x) => x.id == t.id ? t : x).toList();
    // No applyTransaction — stats are derived live from batchStatsProvider
  }
}
