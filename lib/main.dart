import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'core/logger.dart';
import 'features/auth/models/user_model.dart';
import 'features/batches/models/batch_model.dart';
import 'features/feed/models/feed_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BatchAdapter());
  Hive.registerAdapter(FeedEntryAdapter());

  // Set up logger
  AppLogger.init();

  runApp(
    const ProviderScope(
      child: ChickenTrackerApp(),
    ),
  );
}
