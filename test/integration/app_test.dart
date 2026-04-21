import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chicken_tracker/app/app.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('App starts without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ChickenTrackerApp(),
        ),
      );

      await tester.pumpAndSettle();

      // App should load the initial auth screen
      expect(find.text('Auth Screen - To be implemented'), findsOneWidget);
    });
  });
}
