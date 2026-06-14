import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/agents/product_agent.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final body = await context.request.body();
  final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
  
  final transcript = data['transcript'] as String? ?? '';
  
  final agent = context.read<ProductAgent>();
  final result = await agent.analyze(transcript);

  return Response.json(body: result.toJson());
}
