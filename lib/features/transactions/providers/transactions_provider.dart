import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../../batches/providers/batches_provider.dart';

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

    // apply to batch (adjust stock, cash, credit)
    await ref.read(batchesProvider.notifier).applyTransaction(t);
  }

  Future<void> recordSale({
  required String batchId,
  required int quantity,
  required int totalAmountCents,
  required bool isCredit,
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
      // Default creditDate to now, expectedPaymentDate to now + 7 days if not provided
      creditDate: isCredit ? (creditDate ?? now) : null,
      expectedPaymentDate: isCredit
          ? (expectedPaymentDate ?? now.add(const Duration(days: 7)))
          : null,
    );
    await addTransaction(t);
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

  Future<void> recordCreditPayment({
    required String batchId,
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
    );
    await addTransaction(t);
  }
}