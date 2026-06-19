import 'models/transaction_model.dart';

bool isWithdrawalTransaction(TransactionModel t) =>
    t.type == 'withdrawal' || t.type == 'livestock_withdrawal';

String withdrawalTypeLabel(TransactionModel t) {
  switch (t.type) {
    case 'livestock_withdrawal':
      return 'Livestock (personal use)';
    case 'withdrawal':
    default:
      return 'Cash';
  }
}

int repaidAmountForWithdrawal(
  List<TransactionModel> txs,
  String withdrawalId,
) {
  return txs
      .where((t) =>
          t.type == 'withdrawal_repayment' &&
          t.linkedCreditSaleId == withdrawalId)
      .fold(0, (sum, t) => sum + t.amountCents);
}

int remainingWithdrawalAmount(
  List<TransactionModel> txs,
  TransactionModel withdrawal,
) {
  final remaining =
      withdrawal.amountCents - repaidAmountForWithdrawal(txs, withdrawal.id);
  return remaining.clamp(0, 1 << 31);
}

int totalOutstandingWithdrawals(List<TransactionModel> txs) {
  return txs
      .where(isWithdrawalTransaction)
      .fold(0, (sum, t) => sum + remainingWithdrawalAmount(txs, t));
}
