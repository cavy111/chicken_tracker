import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../features/batches/models/batch_model.dart';
import '../../features/batches/providers/batches_provider.dart';

Future<void> showBatchEditDialog(
  BuildContext context,
  WidgetRef ref, {
  Batch? batch,
  String? userId,
}) {
  final nameCtrl = TextEditingController(text: batch?.name ?? '');
  final descCtrl = TextEditingController(text: batch?.description ?? '');
  final initialStockCtrl = TextEditingController(
      text: batch != null ? '${batch.initialStock}' : '');
  final currentStockCtrl = TextEditingController(
      text: batch != null ? '${batch.currentStock}' : '');
  final formKey = GlobalKey<FormState>();
  DateTime selectedStartDate = batch?.startDate ?? DateTime.now();

  String? validateInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Enter a number';
    if (n < 0) return 'Must be 0 or more';
    return null;
  }

  return showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(batch == null ? 'Add Batch' : 'Edit Batch'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: initialStockCtrl,
                decoration: const InputDecoration(labelText: 'Initial Stock'),
                keyboardType: TextInputType.number,
                validator: validateInt,
              ),
              TextFormField(
                controller: currentStockCtrl,
                decoration: const InputDecoration(labelText: 'Current Stock'),
                keyboardType: TextInputType.number,
                validator: validateInt,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Start Date'),
                subtitle: Text(
                  '${selectedStartDate.year}-${selectedStartDate.month.toString().padLeft(2, '0')}-${selectedStartDate.day.toString().padLeft(2, '0')}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedStartDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 730)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedStartDate = picked;
                    });
                  }
                },
              ),
            ],
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
              final id = batch?.id ?? const Uuid().v4();
              final now = DateTime.now();
              final initialStock = int.parse(initialStockCtrl.text.trim());
              final currentStock = int.parse(currentStockCtrl.text.trim());
              final newBatch = Batch(
                id: id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                chickenCount: initialStock,
                initialStock: initialStock,
                currentStock: currentStock,
                cashInHandCents: batch?.cashInHandCents ?? 0,
                outstandingCreditCents: batch?.outstandingCreditCents ?? 0,
                startDate: selectedStartDate,
                endDate: batch?.endDate,
                userId: batch?.userId ?? (userId ?? 'unknown'),
                isActive: batch?.isActive ?? true,
                createdAt: batch?.createdAt ?? now,
                updatedAt: now,
              );
              if (batch == null) {
                await ref.read(batchesProvider.notifier).addBatch(newBatch);
              } else {
                await ref.read(batchesProvider.notifier).updateBatch(newBatch);
              }
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}