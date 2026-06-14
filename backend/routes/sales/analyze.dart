import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/agents/sales_agent.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final body = await context.request.body();
  final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
  
  final sentiment = data['marketing_sentiment'] as int? ?? 80;
  final impactScore = data['product_impact_score'] as int? ?? 50;
  final historicalSales = data['historical_sales'] as int?;
  
  final agent = context.read<SalesAgent>();
  final result = await agent.analyze(sentiment, impactScore, historicalSales);

  return Response.json(body: result.toJson());
}
