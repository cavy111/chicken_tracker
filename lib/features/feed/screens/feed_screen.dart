import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/feed_provider.dart';
import '../models/feed_model.dart';
import '../../batches/providers/batches_provider.dart';
import '../../batches/models/batch_model.dart';
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
      appBar: AppBar(title: const Text('Feed Entries')),
      body: feed.isEmpty
          ? const Center(child: Text('No feed entries yet'))
          : ListView.separated(
              itemCount: feed.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, idx) {
                final e = feed[idx];
                final batchName = batches.firstWhere(
                  (b) => b.id == e.batchId,
                  orElse: () => Batch(
                    id: '',
                    name: 'Unknown',
                    description: '',
                    chickenCount: 0,
                    startDate: DateTime.now(),
                    userId: '',
                    isActive: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ).name;
                return ListTile(
                  title: Text(batchName),
                  subtitle: Text('${e.feedAmount} - ${e.note}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await ref.read(feedProvider.notifier).deleteFeedEntry(e.id);
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
    );
  }

  void _showAddFeedDialog(BuildContext context, WidgetRef ref, List<Batch> batches) {
    final formKey = GlobalKey<FormState>();
    final batchIdHolder = ValueNotifier<String?>(batches.isNotEmpty ? batches.first.id : null);
    final noteCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

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
                    value: value,
                    items: batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
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
                validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter number' : null,
              ),
              TextFormField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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
              );
              await ref.read(feedProvider.notifier).addFeedEntry(entry);

              // show notification
              NotificationService().showNotification(
                title: 'Feed added',
                body: 'Added feed entry for batch',
              );

              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}