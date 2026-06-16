import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/batches_provider.dart';
import '../providers/batch_stats_provider.dart';
import '../models/batch_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/notification_service.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../../shared/utils/date_utils.dart';

enum SalesFilter { today, thisWeek, thisMonth, allTime }

int _paidAmountForCredit(List<TransactionModel> txs, String creditSaleId) {
  return txs
      .where((t) =>
          t.type == 'credit_payment' && t.linkedCreditSaleId == creditSaleId)
      .fold(0, (sum, t) => sum + t.amountCents);
}

int _remainingAmountForCredit(
  List<TransactionModel> txs,
  TransactionModel creditSale,
) {
  final remaining =
      creditSale.amountCents - _paidAmountForCredit(txs, creditSale.id);
  return remaining.clamp(0, 1 << 31);
}

class BatchDetailScreen extends ConsumerStatefulWidget {
  final String batchId;
  const BatchDetailScreen({required this.batchId, super.key});

  @override
  ConsumerState<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends ConsumerState<BatchDetailScreen> {
  SalesFilter _filter = SalesFilter.today;

  @override
  Widget build(BuildContext context) {
    final batches = ref.watch(batchesProvider);
    final batch = batches.firstWhere(
      (b) => b.id == widget.batchId,
      orElse: () => throw Exception('Batch not found'),
    );
    final stats = ref.watch(batchStatsProvider(widget.batchId));

    final batchAgeInDays = AppDateUtils.getBatchAgeInDays(batch.startDate);
    final batchAgeInWeeks = AppDateUtils.getBatchAgeInWeeks(batch.startDate);
    final ageDisplay = AppDateUtils.getBatchAge(batch.startDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (batchAgeInDays > 0 &&
          batchAgeInDays % 7 == 0 &&
          batchAgeInWeeks > 0) {
        NotificationService().showNotification(
          title:
              '${batch.name} is now $batchAgeInWeeks week${batchAgeInWeeks == 1 ? '' : 's'} old',
          body:
              'Your batch has reached $ageDisplay old. Current stock: ${stats.currentStock}',
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(batch.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => ref.read(authProvider.notifier).logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BatchInfoCard(batch: batch, ageDisplay: ageDisplay, stats: stats),
            const SizedBox(height: 10),
            _FilterChips(
              selected: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 10),
            _SalesSummary(batchId: widget.batchId, filter: _filter),
            const SizedBox(height: 16),
            _CreditSalesList(batchId: widget.batchId),
          ],
        ),
      ),
      floatingActionButton: PopupMenuButton<String>(
        icon: const Icon(Icons.add),
        onSelected: (v) {
          if (v == 'sale') _showRecordSale(context, ref, batch);
          if (v == 'withdrawal') _showWithdrawal(context, ref, batch);
          if (v == 'credit_payment') _showCreditPayment(context, ref, batch);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'sale', child: Text('Record Sale')),
          PopupMenuItem(value: 'withdrawal', child: Text('Record Withdrawal')),
          PopupMenuItem(
              value: 'credit_payment', child: Text('Record Credit Payment')),
        ],
      ),
    );
  }

  void _showRecordSale(BuildContext context, WidgetRef ref, Batch batch) {
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final creditorCtrl = TextEditingController();
    bool isCredit = false;
    DateTime creditDate = DateTime.now();
    DateTime expectedPaymentDate = DateTime.now().add(const Duration(days: 7));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Sale'),
        content: StatefulBuilder(builder: (c, setS) {
          return Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: qtyCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Quantity sold'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || int.tryParse(v) == null)
                        ? 'Enter number'
                        : null,
                  ),
                  TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Total amount (e.g., 12.34)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => (v == null || double.tryParse(v) == null)
                        ? 'Enter amount'
                        : null,
                  ),
                  Row(
                    children: [
                      const Text('Credit Sale'),
                      Checkbox(
                        value: isCredit,
                        onChanged: (b) => setS(() => isCredit = b ?? false),
                      ),
                    ],
                  ),
                  if (isCredit) ...[
                    const Divider(),
                    TextFormField(
                      controller: creditorCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Creditor name'),
                      validator: (v) =>
                          (isCredit && (v == null || v.trim().isEmpty))
                              ? 'Enter creditor name'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Credit date: ',
                            style: TextStyle(fontSize: 13)),
                        TextButton(
                          child: Text(
                            '${creditDate.year}-${creditDate.month.toString().padLeft(2, '0')}-${creditDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: c,
                              initialDate: creditDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setS(() => creditDate = picked);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Due date: ',
                            style: TextStyle(fontSize: 13)),
                        TextButton(
                          child: Text(
                            '${expectedPaymentDate.year}-${expectedPaymentDate.month.toString().padLeft(2, '0')}-${expectedPaymentDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: c,
                              initialDate: expectedPaymentDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setS(() => expectedPaymentDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    Text(
                      'Defaults to 1 week from today if not changed',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final qty = int.parse(qtyCtrl.text.trim());
              final amountCents =
                  (double.parse(priceCtrl.text.trim()) * 100).round();
              Navigator.of(context).pop();
              await ref.read(transactionsProvider.notifier).recordSale(
                    batchId: batch.id,
                    quantity: qty,
                    totalAmountCents: amountCents,
                    isCredit: isCredit,
                    creditorName: isCredit ? creditorCtrl.text.trim() : null,
                    creditDate: isCredit ? creditDate : null,
                    expectedPaymentDate: isCredit ? expectedPaymentDate : null,
                  );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawal(BuildContext context, WidgetRef ref, Batch batch) {
    final amtCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Withdrawal'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amtCtrl,
            decoration:
                const InputDecoration(labelText: 'Amount (e.g., 12.34)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => (v == null || double.tryParse(v) == null)
                ? 'Enter amount'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final amountCents =
                  (double.parse(amtCtrl.text.trim()) * 100).round();
              Navigator.of(context).pop();
              await ref.read(transactionsProvider.notifier).recordWithdrawal(
                    batchId: batch.id,
                    amountCents: amountCents,
                  );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCreditPayment(BuildContext context, WidgetRef ref, Batch batch) {
    final amtCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final transactions = ref.read(transactionsProvider);
    final openCredits = transactions
        .where((t) => t.batchId == batch.id && t.type == 'credit_sale')
        .where((t) => _remainingAmountForCredit(transactions, t) > 0)
        .toList()
      ..sort((a, b) => (a.expectedPaymentDate ?? DateTime(9999))
          .compareTo(b.expectedPaymentDate ?? DateTime(9999)));

    if (openCredits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No open credit sales to pay')),
      );
      return;
    }

    String selectedCreditId = openCredits.first.id;
    bool payInFull = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Credit Payment'),
        content: StatefulBuilder(builder: (c, setS) {
          final selectedCredit =
              openCredits.firstWhere((t) => t.id == selectedCreditId);
          final remaining =
              _remainingAmountForCredit(transactions, selectedCredit);
          final paid = _paidAmountForCredit(transactions, selectedCredit.id);

          return Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedCreditId,
                    decoration:
                        const InputDecoration(labelText: 'Credit being paid'),
                    items: openCredits.map((t) {
                      final balance =
                          _remainingAmountForCredit(transactions, t);
                      final name = t.creditorName?.isNotEmpty == true
                          ? t.creditorName!
                          : 'Unknown';
                      return DropdownMenuItem(
                        value: t.id,
                        child: Text(
                          '$name - \$${(balance / 100).toStringAsFixed(2)} left',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setS(() {
                        selectedCreditId = value;
                        amtCtrl.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Original: \$${(selectedCredit.amountCents / 100).toStringAsFixed(2)}  '
                    'Paid: \$${(paid / 100).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pay full remaining balance'),
                    value: payInFull,
                    onChanged: (value) {
                      setS(() {
                        payInFull = value;
                        if (payInFull) {
                          amtCtrl.text = (remaining / 100).toStringAsFixed(2);
                        } else {
                          amtCtrl.clear();
                        }
                      });
                    },
                  ),
                  TextFormField(
                    controller: amtCtrl,
                    enabled: !payInFull,
                    decoration: InputDecoration(
                      labelText: 'Payment amount',
                      hintText: (remaining / 100).toStringAsFixed(2),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (payInFull) return null;
                      final amount = double.tryParse(v ?? '');
                      if (amount == null) return 'Enter amount';
                      final cents = (amount * 100).round();
                      if (cents <= 0) return 'Enter amount above 0';
                      if (cents > remaining) {
                        return 'Amount is more than the remaining balance';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final selectedCredit =
                  openCredits.firstWhere((t) => t.id == selectedCreditId);
              final remaining =
                  _remainingAmountForCredit(transactions, selectedCredit);
              final amountCents = payInFull
                  ? remaining
                  : (double.parse(amtCtrl.text.trim()) * 100).round();
              Navigator.of(context).pop();
              await ref.read(transactionsProvider.notifier).recordCreditPayment(
                    batchId: batch.id,
                    creditSaleId: selectedCredit.id,
                    amountCents: amountCents,
                  );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Batch info card ──────────────────────────────────────────────────────────

class _BatchInfoCard extends StatelessWidget {
  final Batch batch;
  final String ageDisplay;
  final BatchStats stats;
  const _BatchInfoCard({
    required this.batch,
    required this.ageDisplay,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Age: $ageDisplay',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      'Started: ${AppDateUtils.formatDate(batch.startDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Stock',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${stats.currentStock} / ${batch.initialStock}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Cash in hand',
                    value:
                        '\$${(stats.cashInHandCents / 100).toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatTile(
                    label: 'Outstanding credit',
                    value:
                        '\$${(stats.outstandingCreditCents / 100).toStringAsFixed(2)}',
                    valueColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor)),
        ],
      ),
    );
  }
}

// ── Filter chips ─────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final SalesFilter selected;
  final ValueChanged<SalesFilter> onSelected;
  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const labels = {
      SalesFilter.today: 'Today',
      SalesFilter.thisWeek: 'This week',
      SalesFilter.thisMonth: 'This month',
      SalesFilter.allTime: 'All time',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SalesFilter.values.map((f) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(labels[f]!),
              selected: f == selected,
              onSelected: (_) => onSelected(f),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Sales summary pills ───────────────────────────────────────────────────────

class _SalesSummary extends ConsumerWidget {
  final String batchId;
  final SalesFilter filter;
  const _SalesSummary({required this.batchId, required this.filter});

  bool _inRange(DateTime date, SalesFilter filter) {
    final now = DateTime.now();
    return switch (filter) {
      SalesFilter.today =>
        date.year == now.year && date.month == now.month && date.day == now.day,
      SalesFilter.thisWeek =>
        date.isAfter(now.subtract(const Duration(days: 7))),
      SalesFilter.thisMonth => date.year == now.year && date.month == now.month,
      SalesFilter.allTime => true,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref
        .watch(transactionsProvider)
        .where((t) => t.batchId == batchId && _inRange(t.date, filter))
        .toList();

    final cashSales = txs.where((t) => t.type == 'sale').toList();
    final creditSales = txs.where((t) => t.type == 'credit_sale').toList();

    final cashCount = cashSales.fold(0, (sum, t) => sum + (t.quantity ?? 1));
    final creditCount =
        creditSales.fold(0, (sum, t) => sum + (t.quantity ?? 1));

    final cashTotal = cashSales.fold(0, (sum, t) => sum + t.amountCents);
    final creditTotal = creditSales.fold(0, (sum, t) => sum + t.amountCents);
    const labels = {
      SalesFilter.today: 'today',
      SalesFilter.thisWeek: 'this week',
      SalesFilter.thisMonth: 'this month',
      SalesFilter.allTime: 'all time',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales — ${labels[filter]}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SummaryPill(
                    label: 'Cash sales',
                    count: cashCount,
                    total: cashTotal,
                    color: Colors.green.shade50,
                    textColor: Colors.green.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryPill(
                    label: 'Credit sales',
                    count: creditCount,
                    total: creditTotal,
                    color: Colors.orange.shade50,
                    textColor: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final Color textColor;
  const _SummaryPill({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: textColor)),
          Text('$count chicken${count == 1 ? '' : 's'}',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w600, color: textColor)),
          Text('\$${(total / 100).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 11, color: textColor)),
        ],
      ),
    );
  }
}

// ── Credit sales list ────────────────────────────────────────────────────────

class _CreditSalesList extends ConsumerWidget {
  final String batchId;
  const _CreditSalesList({required this.batchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsProvider);
    final credits = txs
        .where((t) => t.batchId == batchId && t.type == 'credit_sale')
        .where((t) => _remainingAmountForCredit(txs, t) > 0)
        .toList()
      ..sort((a, b) => (a.expectedPaymentDate ?? DateTime(9999))
          .compareTo(b.expectedPaymentDate ?? DateTime(9999)));

    if (credits.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
            child:
                Text('No credit sales', style: TextStyle(color: Colors.grey))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Credit sales',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            Text('${credits.length} open',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        ...credits.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CreditSaleCard(transaction: t),
            )),
      ],
    );
  }
}

class _CreditSaleCard extends ConsumerWidget {
  final TransactionModel transaction;
  const _CreditSaleCard({required this.transaction});

  String _fmt(DateTime? d) => d == null
      ? '—'
      : '${d.day} ${[
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ][d.month - 1]}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsProvider);
    final paid = _paidAmountForCredit(txs, transaction.id);
    final remaining = _remainingAmountForCredit(txs, transaction);
    final now = DateTime.now();
    final due = transaction.expectedPaymentDate;
    final daysUntilDue = due?.difference(now).inDays;
    final isOverdue = daysUntilDue != null && daysUntilDue < 0;
    final isDueSoon =
        daysUntilDue != null && daysUntilDue >= 0 && daysUntilDue <= 3;

    final borderColor = isOverdue
        ? Colors.red.shade400
        : isDueSoon
            ? Colors.orange.shade400
            : Colors.grey.shade300;

    final badgeText = isOverdue
        ? 'Overdue'
        : daysUntilDue == 0
            ? 'Due today'
            : daysUntilDue != null
                ? 'Due in $daysUntilDue day${daysUntilDue == 1 ? '' : 's'}'
                : '';

    final badgeColor = isOverdue
        ? Colors.red.shade50
        : isDueSoon
            ? Colors.orange.shade50
            : Colors.grey.shade100;

    final badgeTextColor = isOverdue
        ? Colors.red.shade800
        : isDueSoon
            ? Colors.orange.shade800
            : Colors.grey.shade700;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored left bar
              Container(width: 4, color: borderColor),
              // Card content
              Expanded(
                child: Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.creditorName?.isNotEmpty == true
                                      ? transaction.creditorName!
                                      : 'Unknown',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                if (transaction.quantity != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      '${transaction.quantity} chickens',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${(remaining / 100).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                paid > 0
                                    ? '\$${(paid / 100).toStringAsFixed(2)} paid'
                                    : '\$${(transaction.amountCents / 100).toStringAsFixed(2)} total',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              if (badgeText.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(badgeText,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: badgeTextColor)),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Sold ${_fmt(transaction.creditDate)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.schedule_outlined,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('Due ${_fmt(due)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _showEditDialog(context, ref),
                            child: const Icon(Icons.edit_outlined,
                                size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final paid =
        _paidAmountForCredit(ref.read(transactionsProvider), transaction.id);
    final creditorCtrl =
        TextEditingController(text: transaction.creditorName ?? '');
    final amountCtrl = TextEditingController(
        text: (transaction.amountCents / 100).toStringAsFixed(2));
    final qtyCtrl =
        TextEditingController(text: transaction.quantity?.toString() ?? '');
    DateTime creditDate = transaction.creditDate ?? DateTime.now();
    DateTime expectedPaymentDate = transaction.expectedPaymentDate ??
        DateTime.now().add(const Duration(days: 7));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Credit Sale'),
        content: StatefulBuilder(builder: (c, setS) {
          return Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: creditorCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Creditor name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter creditor name'
                        : null,
                  ),
                  TextFormField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || int.tryParse(v) == null)
                        ? 'Enter number'
                        : null,
                  ),
                  TextFormField(
                    controller: amountCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Amount (e.g., 12.34)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final amount = double.tryParse(v ?? '');
                      if (amount == null) return 'Enter amount';
                      if ((amount * 100).round() < paid) {
                        return 'Amount cannot be less than payments already made';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Credit date: ',
                          style: TextStyle(fontSize: 13)),
                      TextButton(
                        child: Text(
                          '${creditDate.year}-${creditDate.month.toString().padLeft(2, '0')}-${creditDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: c,
                            initialDate: creditDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setS(() => creditDate = picked);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Due date: ', style: TextStyle(fontSize: 13)),
                      TextButton(
                        child: Text(
                          '${expectedPaymentDate.year}-${expectedPaymentDate.month.toString().padLeft(2, '0')}-${expectedPaymentDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: c,
                            initialDate: expectedPaymentDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setS(() => expectedPaymentDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final now = DateTime.now();
              final updated = TransactionModel(
                id: transaction.id,
                batchId: transaction.batchId,
                type: transaction.type,
                amountCents:
                    (double.parse(amountCtrl.text.trim()) * 100).round(),
                quantity: int.tryParse(qtyCtrl.text.trim()),
                isCredit: transaction.isCredit,
                note: transaction.note,
                date: transaction.date,
                userId: transaction.userId,
                createdAt: transaction.createdAt,
                updatedAt: now,
                creditorName: creditorCtrl.text.trim(),
                creditDate: creditDate,
                expectedPaymentDate: expectedPaymentDate,
                linkedCreditSaleId: transaction.linkedCreditSaleId,
              );
              Navigator.of(context).pop();
              await ref
                  .read(transactionsProvider.notifier)
                  .updateTransaction(updated);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
