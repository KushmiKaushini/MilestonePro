// Milestone Pro — widget smoke test
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milestone_pro/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MilestoneProApp()),
    );
    // App should render — Isar initialises asynchronously so we just check
    // the widget tree builds without throwing.
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
