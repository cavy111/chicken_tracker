import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../batches/providers/batches_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/batch_edit_dialog.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

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
                  'Stock: ${b.currentStock} | Sale: \$${(b.salePriceCents / 100).toStringAsFixed(2)} | Stock cost: \$${(b.stockCostCents / 100).toStringAsFixed(2)}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () => showBatchEditDialog(context, ref, batch: b),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
