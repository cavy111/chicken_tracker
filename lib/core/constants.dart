class AppConstants {
  // App
  static const String appName = 'Chicken Tracker';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String batchesCollection = 'batches';
  static const String feedCollection = 'feed';
  static const String notificationsCollection = 'notifications';

  // Shared Preferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String userThemeKey = 'user_theme';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxBatchNameLength = 50;
  static const int maxFeedNoteLength = 500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration shortCacheDuration = Duration(minutes: 5);
}

class FirestoreConstants {
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String createdBy = 'createdBy';
  static const String userId = 'userId';
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String isActive = 'isActive';
}
