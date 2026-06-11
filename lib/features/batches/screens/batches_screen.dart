import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/batch_model.dart';
import '../providers/batches_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/confirm_dialog.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(batchesProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      body: batches.isEmpty
          ? const Center(child: Text('No batches yet'))
          : ListView.separated(
              itemCount: batches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final b = batches[idx];
                return ListTile(
                  title: Text(b.name),
                  subtitle: Text('${b.chickenCount} chickens'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showBatchDialog(context, ref, batch: b);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showConfirmDialog(
                              context, 'Delete batch?', 'Are you sure?');
                          if (confirm == true) {
                            await ref
                                .read(batchesProvider.notifier)
                                .deleteBatch(b.id);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBatchDialog(context, ref, userId: auth.userId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBatchDialog(BuildContext context, WidgetRef ref,
      {Batch? batch, String? userId}) {
    final nameCtrl = TextEditingController(text: batch?.name ?? '');
    final descCtrl = TextEditingController(text: batch?.description ?? '');
    final countCtrl =
        TextEditingController(text: batch != null ? '${batch.chickenCount}' : '');
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(batch == null ? 'Add Batch' : 'Edit Batch'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: countCtrl,
                decoration: const InputDecoration(labelText: 'Chicken Count'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || int.tryParse(v) == null) ? 'Enter a number' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final id = batch?.id ?? const Uuid().v4();
              final now = DateTime.now();
              final newBatch = Batch(
                id: id,
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                chickenCount: int.parse(countCtrl.text.trim()),
                startDate: batch?.startDate ?? now,
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
    );
  }
}