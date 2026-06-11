import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/feed_model.dart';

class FeedNotifier extends StateNotifier<List<FeedEntry>> {
  FeedNotifier() : super([]) {
    _loadFeedEntries();
  }

  Future<void> _loadFeedEntries() async {
    final box = await Hive.openBox<FeedEntry>('feed');
    state = box.values.toList();
  }

  Future<void> addFeedEntry(FeedEntry entry) async {
    final box = await Hive.openBox<FeedEntry>('feed');
    await box.put(entry.id, entry);
    state = [...state, entry];
  }

  Future<void> updateFeedEntry(FeedEntry entry) async {
    final box = await Hive.openBox<FeedEntry>('feed');
    await box.put(entry.id, entry);
    state = state.map((e) => e.id == entry.id ? entry : e).toList();
  }

  Future<void> deleteFeedEntry(String entryId) async {
    final box = await Hive.openBox<FeedEntry>('feed');
    await box.delete(entryId);
    state = state.where((e) => e.id != entryId).toList();
  }

  Future<void> getFeedByBatchId(String batchId) async {
    final box = await Hive.openBox<FeedEntry>('feed');
    state = box.values.where((entry) => entry.batchId == batchId).toList();
  }

  Future<void> getFeedByUserId(String userId) async {
    final box = await Hive.openBox<FeedEntry>('feed');
    state = box.values.where((entry) => entry.userId == userId).toList();
  }
}

final feedProvider =
    StateNotifierProvider<FeedNotifier, List<FeedEntry>>((ref) {
  return FeedNotifier();
});
