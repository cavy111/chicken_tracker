import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../batches/models/batch_model.dart';
import '../../batches/providers/batches_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(batchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Edit batch details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          if (batches.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No batches yet'),
            )
          else
            ...batches.map(
              (b) => ListTile(
                title: Text(b.name),
                subtitle: Text(
                    'Stock: ${b.currentStock} | Initial: ${b.initialStock}'),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditBatchDialog(context, ref, b),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.egg), label: 'Batches'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 0) {
            context.go('/batches');
          } else if (index == 1) {
            context.go('/feed');
          }
        },
      ),
    );
  }

  void _showEditBatchDialog(BuildContext context, WidgetRef ref, Batch batch) {
    final nameCtrl = TextEditingController(text: batch.name);
    final descCtrl = TextEditingController(text: batch.description);
    final initialStockCtrl =
        TextEditingController(text: '${batch.initialStock}');
    final currentStockCtrl =
        TextEditingController(text: '${batch.currentStock}');
    final formKey = GlobalKey<FormState>();

    String? validateInt(String? v) {
      if (v == null || v.trim().isEmpty) return 'Required';
      final n = int.tryParse(v.trim());
      if (n == null) return 'Enter a number';
      if (n < 0) return 'Must be 0 or more';
      return null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Batch'),
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
              final initialStock = int.parse(initialStockCtrl.text.trim());
              final currentStock = int.parse(currentStockCtrl.text.trim());
              final updated = batch.copyWith(
                name: nameCtrl.text.trim(),
                description: descCtrl.text.trim(),
                chickenCount: initialStock,
                initialStock: initialStock,
                currentStock: currentStock,
                updatedAt: DateTime.now(),
              );
              await ref.read(batchesProvider.notifier).updateBatch(updated);
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
