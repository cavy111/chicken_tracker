import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/batches_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/utils/date_utils.dart';
import '../../../shared/widgets/batch_edit_dialog.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batches = ref.watch(batchesProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batches'),
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
      body: batches.isEmpty
          ? const Center(child: Text('No batches yet'))
          : ListView.separated(
              itemCount: batches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final b = batches[idx];
                final batchAge = AppDateUtils.getBatchAge(b.startDate);
                return ListTile(
                  title: Text(b.name),
                  subtitle: Text('Stock: ${b.currentStock} | Age: $batchAge'),
                  onTap: () => context.push('/batches/${b.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showBatchEditDialog(context, ref, batch: b);
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
        onPressed: () => showBatchEditDialog(context, ref, userId: auth.userId),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.egg), label: 'Batches'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 1) {
            context.go('/feed');
          } else if (index == 2) {
            context.go('/settings');
          }
        },
      ),
    );
  }
}