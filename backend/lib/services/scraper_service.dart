import 'dart:convert';
import 'package:http/http.dart' as http;

class ScraperService {
  Future<Map<String, dynamic>> fetchMentions(String product) async {
    // In a real application, this would call actual APIs (Twitter, Reddit, etc.)
    // For this stateless AI backend without external keys, we mock the result
    // based on the product name.
    
    // Simulate HTTP delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return {
      'source': 'Twitter',
      'comments': [
        'Love the camera on $product!',
        '$product gets too hot when gaming.',
        'Battery life could be better on the $product.',
        'The display on $product is amazing.',
      ],
    };
  }
}
