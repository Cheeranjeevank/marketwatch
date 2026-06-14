import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:marketwatch_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MarketWatch App Automation', () {
    testWidgets('Verify Marketing, Product, Sales, and Strategy features', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 1. Marketing Agent Check
      print("Testing Marketing Agent...");
      final marketingTab = find.byIcon(Icons.campaign).last;
      await tester.tap(marketingTab);
      await tester.pumpAndSettle();
      
      // Enter mock ad text
      final adInput = find.byType(TextField).last;
      await tester.ensureVisible(adInput);
      await tester.enterText(adInput, 'Amazing product, high return on ad spend');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final analyzeCampaignBtn = find.text('RUN PROFIT ANALYSIS');
      expect(analyzeCampaignBtn, findsOneWidget);
      await tester.ensureVisible(analyzeCampaignBtn);
      await tester.tap(analyzeCampaignBtn);
      await tester.pump(const Duration(milliseconds: 500));
      // Wait for AI service response
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.textContaining('SENTIMENT SCORE'), findsOneWidget);

      // 2. Product Agent Check
      print("Testing Product Agent...");
      final productTab = find.byIcon(Icons.inventory).last;
      await tester.tap(productTab);
      await tester.pumpAndSettle();

      // Enter mock review text
      final reviewInput = find.byType(TextField).first;
      await tester.ensureVisible(reviewInput);
      await tester.enterText(reviewInput, 'The product is missing the main charging cable');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final analyzeComplaintsBtn = find.text('ANALYZE COMPLAINTS');
      expect(analyzeComplaintsBtn, findsOneWidget);
      await tester.ensureVisible(analyzeComplaintsBtn);
      await tester.tap(analyzeComplaintsBtn);
      await tester.pump(const Duration(milliseconds: 500));
      // Wait for processing
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.textContaining('Main Issue:'), findsOneWidget);

      // 3. Sales Agent Check
      print("Testing Sales Agent...");
      final salesTab = find.byIcon(Icons.monetization_on).last;
      await tester.tap(salesTab);
      await tester.pumpAndSettle();

      final checkProfitBtn = find.text('CHECK AD PROFIT');
      expect(checkProfitBtn, findsOneWidget);
      
      // Enter some dummy text in the inputs to pass validation
      final inputs = find.byType(TextFormField);
      await tester.ensureVisible(inputs.at(0));
      await tester.enterText(inputs.at(0), 'B07XYZ1234');
      await tester.ensureVisible(inputs.at(1));
      await tester.enterText(inputs.at(1), 'Electronics');
      await tester.ensureVisible(inputs.at(3));
      await tester.enterText(inputs.at(3), 'Increased bid price by 20%');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.ensureVisible(checkProfitBtn);
      await tester.tap(checkProfitBtn);
      await tester.pump(const Duration(milliseconds: 500));
      // Wait for AI response
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.textContaining('PROFIT HEALTH:'), findsOneWidget);

      // 4. Strategy Agent Check
      print("Testing Strategy Agent...");
      final strategyTab = find.byIcon(Icons.insights).last;
      await tester.tap(strategyTab);
      await tester.pumpAndSettle();

      final askAdviceBtn = find.text('Ask for Advice');
      expect(askAdviceBtn, findsOneWidget);
      await tester.ensureVisible(askAdviceBtn);
      await tester.tap(askAdviceBtn);
      await tester.pump(const Duration(milliseconds: 500));
      
      // Wait for strategy response
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.textContaining('Playbook Step'), findsWidgets);
      
      print("All features verified successfully via Automation!");
    });
  });
}
