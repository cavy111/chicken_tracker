import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'core/logger.dart';
import 'features/auth/models/user_model.dart';
import 'features/batches/models/batch_model.dart';
import 'features/feed/models/feed_model.dart';
import 'features/notifications/notification_service.dart';
import 'features/transactions/models/transaction_model.dart';
import 'features/weekly/models/weekly_snapshot.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(BatchAdapter());
  Hive.registerAdapter(FeedEntryAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(WeeklySnapshotAdapter());

  // Set up logger
  AppLogger.init();

  // Initialize local notifications
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: ChickenTrackerApp(),
    ),
  );
}