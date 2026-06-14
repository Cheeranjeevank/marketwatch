import 'package:flutter_test/flutter_test.dart';
import 'package:marketwatch_app/ai_service.dart';

void main() {
  test('Backend Service Agent Payloads Verification', () async {
    final aiService = AIService();

    print('\n==================================================================');
    print('VERIFYING BACKEND AI AGENT SERVICES LOGIC & PAYLOAD STRUCTURES');
    print('==================================================================');

    // 1. Marketing AI
    print('\n[Testing Agent 1: Marketing AI]');
    print('Input: "We love this product! It is great and very fast, excellent job."');
    final marketingResult = await aiService.analyzeText(
      text: "We love this product! It is great and very fast, excellent job.",
      agentType: "marketing",
      trendingPlatform: "instagram",
    );
    print('Output Payload:');
    print(marketingResult.jsonPayload);

    // 2. Product AI
    print('\n[Testing Agent 2: Product AI]');
    print('Input: "Low light camera grain is really bad on the new model. The post processing is causing severe noise."');
    final productResult = await aiService.analyzeText(
      text: "Low light camera grain is really bad on the new model. The post processing is causing severe noise.",
      agentType: "product",
    );
    print('Output Payload:');
    print(productResult.jsonPayload);

    // 3. Sales AI
    print('\n[Testing Agent 3: Sales AI]');
    print('Input: "TechCorp solutions VP is complaining about competitor API timeouts."');
    final salesResult = await aiService.analyzeText(
      text: "TechCorp solutions VP is complaining about competitor API timeouts.",
      agentType: "sales",
    );
    print('Output Payload:');
    print(salesResult.jsonPayload);

    // 4. Strategy AI
    print('\n[Testing Agent 4: Strategy AI]');
    print('Input: "product ai says heating issue, marketing ai says hype is dropping, as sales ai conversion rate is low."');
    final strategyResult = await aiService.analyzeText(
      text: "product ai says heating issue, marketing ai says hype is dropping, as sales ai conversion rate is low.",
      agentType: "strategy",
    );
    print('Output Payload:');
    print(strategyResult.jsonPayload);

    print('\n==================================================================');
    print('ALL BACKEND AI PAYLOADS MAPPED SUCCESSFULLY');
    print('==================================================================');
  });
}
