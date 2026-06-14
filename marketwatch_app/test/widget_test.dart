import 'package:flutter_test/flutter_test.dart';
import 'package:marketwatch_app/main.dart';

void main() {
  testWidgets('MarketWatch AI Cockpit rendering test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarketWatchApp());

    // Verify that the Cockpit title is found.
    expect(find.text('MarketWatch'), findsOneWidget);
    expect(find.text('| AI Agent Cockpit'), findsOneWidget);
  });
}
