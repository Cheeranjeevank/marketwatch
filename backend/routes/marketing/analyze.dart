import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/agents/marketing_agent.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final body = await context.request.body();
  final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
  
  final product = data['product'] as String? ?? 'Unknown Product';
  final extractedText = data['extracted_text'] as String? ?? 'No scraped text provided';
  final platform = data['trending_platform'] as String? ?? 'Twitter';
  
  final agent = context.read<MarketingAgent>();
  final result = await agent.analyze(product, extractedText, platform);

  return Response.json(body: result.toJson());
}
