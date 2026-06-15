import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/batches_provider.dart';
import '../models/batch_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/notification_service.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../../shared/utils/date_utils.dart';

class BatchDetailScreen extends ConsumerWidget {
  final String batchId;
  const BatchDetailScreen({required this.batchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(batchesProvider);
    final batch = batches.firstWhere((b) => b.id == batchId, orElse: () => throw Exception('Batch not found'));

    // Calculate batch age and check for milestones
    final batchAgeInDays = AppDateUtils.getBatchAgeInDays(batch.startDate);
    final batchAgeInWeeks = AppDateUtils.getBatchAgeInWeeks(batch.startDate);
    final ageDisplay = AppDateUtils.getBatchAge(batch.startDate);

    // Show notification if batch reached a week milestone
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (batchAgeInDays > 0 && batchAgeInDays % 7 == 0 && batchAgeInWeeks > 0) {
        NotificationService().showNotification(
          title: '${batch.name} is now $batchAgeInWeeks week${batchAgeInWeeks == 1 ? '' : 's'} old',
          body: 'Your batch has reached $ageDisplay old. Current stock: ${batch.currentStock}',
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
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Batch Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Age: $ageDisplay',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Started: ${AppDateUtils.formatDate(batch.startDate)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text('Stock: ${batch.currentStock}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Initial Stock: ${batch.initialStock}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('Cash: \$${(batch.cashInHandCents / 100).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                    Text('Outstanding Credit: \$${(batch.outstandingCreditCents / 100).toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: Colors.orange)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: TransactionList(batchId: batchId)),
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
          PopupMenuItem(value: 'credit_payment', child: Text('Record Credit Payment')),
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
                    decoration: const InputDecoration(labelText: 'Quantity sold'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || int.tryParse(v) == null) ? 'Enter number' : null,
                  ),
                  TextFormField(
                    controller: priceCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Total amount (e.g., 12.34)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        (v == null || double.tryParse(v) == null) ? 'Enter amount' : null,
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

                  // Credit-only fields
                  if (isCredit) ...[
                    const Divider(),
                    TextFormField(
                      controller: creditorCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Creditor name'),
                      validator: (v) => (isCredit && (v == null || v.trim().isEmpty))
                          ? 'Enter creditor name'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Credit date picker
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

                    // Expected payment date picker
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
              await ref.read(transactionsProvider.notifier).recordSale(
                    batchId: batch.id,
                    quantity: qty,
                    totalAmountCents: amountCents,
                    isCredit: isCredit,
                    creditorName: isCredit ? creditorCtrl.text.trim() : null,
                    creditDate: isCredit ? creditDate : null,
                    expectedPaymentDate: isCredit ? expectedPaymentDate : null,
                  );
              if (!context.mounted) return;
              Navigator.of(context).pop();
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
            decoration: const InputDecoration(labelText: 'Amount (e.g., 12.34)'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter amount' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final amountCents = (double.parse(amtCtrl.text.trim()) * 100).round();
              await ref.read(transactionsProvider.notifier).recordWithdrawal(
                    batchId: batch.id,
                    amountCents: amountCents,
                  );
              if (!context.mounted) return;
              Navigator.of(context).pop();
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Credit Payment'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amtCtrl,
            decoration: const InputDecoration(labelText: 'Amount (e.g., 12.34)'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter amount' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final amountCents = (double.parse(amtCtrl.text.trim()) * 100).round();
              await ref.read(transactionsProvider.notifier).recordCreditPayment(
                    batchId: batch.id,
                    amountCents: amountCents,
                  );
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class TransactionList extends ConsumerWidget {
  final String batchId;
  const TransactionList({required this.batchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsProvider);
    final list = txs.where((t) => t.batchId == batchId).toList().reversed.toList();

    if (list.isEmpty) return const Center(child: Text('No transactions yet'));

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, idx) {
        final t = list[idx];
        return ListTile(
          title: Text('${t.type} ${(t.quantity != null) ? 'x${t.quantity}' : ''}'),
          subtitle: Text(t.note ?? ''),
          trailing: Text('\$${(t.amountCents/100).toStringAsFixed(2)}'),
        );
      },
    );
  }
}