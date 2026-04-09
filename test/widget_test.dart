import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milestone_pro/app.dart';

void main() {
  testWidgets('Dashboard load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MilestoneProApp(),
      ),
    );

    // Verify that the app title exists
    expect(find.text('Milestone Pro'), findsWidgets);
  });
}
