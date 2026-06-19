import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../batches/models/batch_model.dart';
import '../../batches/providers/batches_provider.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../transactions/withdrawal_utils.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

class WithdrawalsScreen extends ConsumerWidget {
  const WithdrawalsScreen({super.key});

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

  String _batchName(List<Batch> batches, String batchId) {
    return batches
        .where((b) => b.id == batchId)
        .map((b) => b.name)
        .firstOrNull ?? 'Unknown batch';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsProvider);
    final batches = ref.watch(batchesProvider);

    final withdrawals = txs.where(isWithdrawalTransaction).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalWithdrawn =
        withdrawals.fold(0, (sum, t) => sum + t.amountCents);
    final totalOutstanding = totalOutstandingWithdrawals(txs);
    final totalRepaid = totalWithdrawn - totalOutstanding;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdrawals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: withdrawals.isEmpty
          ? const Center(child: Text('No withdrawals yet'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          label: 'Total withdrawn',
                          value: _money(totalWithdrawn),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Outstanding',
                          value: _money(totalOutstanding),
                          valueColor: totalOutstanding > 0
                              ? Colors.orange.shade800
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Repaid',
                          value: _money(totalRepaid),
                          valueColor: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: withdrawals.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final t = withdrawals[idx];
                      final remaining = remainingWithdrawalAmount(txs, t);
                      final repaid = repaidAmountForWithdrawal(txs, t.id);
                      final isPaidOff = remaining == 0;

                      return ListTile(
                        title: Text(
                          t.note?.isNotEmpty == true
                              ? t.note!
                              : withdrawalTypeLabel(t),
                        ),
                        subtitle: Text(
                          '${_batchName(batches, t.batchId)} · '
                          '${withdrawalTypeLabel(t)} · ${_fmt(t.date)}'
                          '${t.quantity != null ? ' · ${t.quantity} chickens' : ''}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isPaidOff
                                  ? _money(t.amountCents)
                                  : _money(remaining),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isPaidOff
                                    ? Colors.grey.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                            Text(
                              isPaidOff
                                  ? 'Paid back'
                                  : repaid > 0
                                      ? '${_money(repaid)} repaid'
                                      : 'Outstanding',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () => context.push('/batches/${t.batchId}'),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
