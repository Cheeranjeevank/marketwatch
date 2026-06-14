import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/agents/strategy_agent.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final body = await context.request.body();
  final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
  
  final marketingSummary = data['marketing_summary'] as String? ?? '';
  final productPainPoint = data['product_pain_point'] as String? ?? '';
  final salesForecast = data['sales_forecast'] as String? ?? '';
  
  final agent = context.read<StrategyAgent>();
  final result = await agent.analyze(
    marketingSummary,
    productPainPoint,
    salesForecast,
  );

  return Response.json(body: result.toJson());
}
