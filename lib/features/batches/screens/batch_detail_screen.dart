import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/batches_provider.dart';
import '../models/batch_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/providers/transactions_provider.dart';

class BatchDetailScreen extends ConsumerWidget {
  final String batchId;
  const BatchDetailScreen({required this.batchId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(batchesProvider);
    final batch = batches.firstWhere((b) => b.id == batchId, orElse: () => throw Exception('Batch not found'));

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
            Card(
              child: ListTile(
                title: Text('Stock: ${batch.currentStock}'),
                subtitle: Text('Cash: ${(batch.cashInHandCents / 100).toStringAsFixed(2)} | Outstanding: ${(batch.outstandingCreditCents/100).toStringAsFixed(2)}'),
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
    bool isCredit = false;
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Sale'),
        content: StatefulBuilder(builder: (c, setS) {
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Quantity sold'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter number' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Total amount (e.g., 12.34)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter amount' : null,
                ),
                Row(
                  children: [
                    const Text('Credit'),
                    Checkbox(value: isCredit, onChanged: (b) => setS(() => isCredit = b ?? false)),
                  ],
                ),
              ],
            ),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final qty = int.parse(qtyCtrl.text.trim());
              final amountDouble = double.parse(priceCtrl.text.trim());
              final amountCents = (amountDouble * 100).round();
              await ref.read(transactionsProvider.notifier).recordSale(
                    batchId: batch.id,
                    quantity: qty,
                    totalAmountCents: amountCents,
                    isCredit: isCredit,
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