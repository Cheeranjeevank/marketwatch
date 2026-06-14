class SentimentService {
  String generateSummary(List<String> rawComments, Map<String, dynamic> tfLiteOutput) {
    // Simulating context aware summarization
    if ((tfLiteOutput['sentiment'] as int) > 80) {
      return 'Positive discussions about battery performance are increasing rapidly.';
    } else {
      return 'Twitter conversations increased 38% in the last 24 hours. Most users praise camera quality but complain about heating.';
    }
  }

  String extractPainPoint(String transcript, Map<String, dynamic> tfLiteOutput) {
    if (transcript.toLowerCase().contains('heating')) {
      return 'Device heating during charging';
    }
    return 'Low-light camera grain';
  }

  String extractRecommendation(String category) {
    if (category == 'Camera') {
      return 'Improve image processing in low-light environments';
    } else if (category == 'Heating') {
      return 'Optimize thermal throttling profiles';
    }
    return 'General performance patch required';
  }
}
