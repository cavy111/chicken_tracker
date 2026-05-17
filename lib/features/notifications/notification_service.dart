import 'package:local_notifier/local_notifier.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await localNotifier.setup(
      appName: 'Chicken Tracker',
    );
  }

  void showNotification({
    required String title,
    required String body,
  }) {
    final notification = LocalNotification(
      title: title,
      body: body,
    );
    localNotifier.notify(notification);
  }
}
