import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../providers/feed_provider.dart';
import '../models/feed_model.dart';
import '../../batches/providers/batches_provider.dart';
import '../../batches/models/batch_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/notification_service.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final batches = ref.watch(batchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Entries'),
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
      body: feed.isEmpty
          ? const Center(child: Text('No feed entries yet'))
          : ListView.separated(
              itemCount: feed.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, idx) {
                final e = feed[idx];
                final batch = batches.firstWhere(
                  (b) => b.id == e.batchId,
                  orElse: () => Batch(
                    id: '',
                    name: 'Unknown',
                    description: '',
                    chickenCount: 0,
                    initialStock: 0,
                    currentStock: 0,
                    cashInHandCents: 0,
                    outstandingCreditCents: 0,
                    startDate: DateTime.now(),
                    userId: '',
                    isActive: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                return ListTile(
                  title: Text(batch.name),
                  subtitle: Text(
                    '${e.feedAmount} - \$${(e.feedCostCents / 100).toStringAsFixed(2)} - ${e.note}',
                  ),
                  onTap: batch.id.isNotEmpty
                      ? () => context.push('/batches/${batch.id}')
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await ref
                              .read(feedProvider.notifier)
                              .deleteFeedEntry(e.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFeedDialog(context, ref, batches),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.egg), label: 'Batches'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 0) {
            context.go('/batches');
          } else if (index == 2) {
            context.go('/settings');
          }
        },
      ),
    );
  }

  void _showAddFeedDialog(
      BuildContext context, WidgetRef ref, List<Batch> batches) {
    final formKey = GlobalKey<FormState>();
    final batchIdHolder =
        ValueNotifier<String?>(batches.isNotEmpty ? batches.first.id : null);
    final noteCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Feed Entry'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: batchIdHolder,
                builder: (_, value, __) {
                  return DropdownButtonFormField<String>(
                    initialValue: value,
                    items: batches
                        .map((b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.name)))
                        .toList(),
                    onChanged: (v) => batchIdHolder.value = v,
                    decoration: const InputDecoration(labelText: 'Batch'),
                    validator: (v) => v == null ? 'Select a batch' : null,
                  );
                },
              ),
              TextFormField(
                controller: amountCtrl,
                decoration: const InputDecoration(labelText: 'Feed Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || int.tryParse(v) == null)
                    ? 'Enter number'
                    : null,
              ),
              TextFormField(
                controller: costCtrl,
                decoration:
                    const InputDecoration(labelText: 'Feed cost (optional)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final amount = double.tryParse(v);
                  if (amount == null) return 'Enter amount';
                  if (amount < 0) return 'Must be 0 or more';
                  return null;
                },
              ),
              TextFormField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final id = const Uuid().v4();
              final now = DateTime.now();
              final entry = FeedEntry(
                id: id,
                batchId: batchIdHolder.value!,
                note: noteCtrl.text.trim(),
                imageUrl: null,
                feedAmount: int.parse(amountCtrl.text.trim()),
                feedTime: now,
                userId: 'local', // keep simple for now
                createdAt: now,
                updatedAt: now,
                feedCostCents: costCtrl.text.trim().isEmpty
                    ? 0
                    : (double.parse(costCtrl.text.trim()) * 100).round(),
              );
              await ref.read(feedProvider.notifier).addFeedEntry(entry);

              // show notification
              NotificationService().showNotification(
                title: 'Feed added',
                body: 'Added feed entry for batch',
              );

              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
