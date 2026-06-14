class MarketingResponse {
  MarketingResponse({
    required this.sentiment,
    required this.trendingPlatform,
    required this.trendScore,
    required this.summary,
    required this.scrapedText,
    required this.tfliteRawOutput,
    required this.impactScore,
    this.agentName = 'marketing',
  });

  final String agentName;
  final int sentiment;
  final String trendingPlatform;
  final int trendScore;
  final String summary;
  
  final String scrapedText;
  final double tfliteRawOutput;
  final double impactScore;

  Map<String, dynamic> toJson() {
    final recommendation = sentiment > 70 
        ? "Capitalize on positive organic growth; increase ad spend."
        : "Deploy positive PR statement and target retention discounts.";

    return {
      'Agent': agentName,
      'Sentiment': sentiment,
      'TrendingPlatform': trendingPlatform,
      'TrendScore': trendScore,
      'Layer1_Scrape': {
        'source': trendingPlatform,
        'status': 'completed',
        'extracted_text': scrapedText,
      },
      'Layer2_TFLite_Priority_Weighting': {
        'using_tflite': true,
        'tflite_raw_output': tfliteRawOutput,
        'priority_weight': impactScore,
      },
      'Layer3_Context_Aware_Summarization': {
        'summary': summary,
        'actionable_recommendation': recommendation,
      }
    };
  }
}

class ProductResponse {
  ProductResponse({
    required this.timestamp,
    required this.painPoint,
    required this.category,
    required this.impactScore,
    required this.sentiment,
    required this.recommendation,
    this.agentName = 'Product_AI',
  });

  final String agentName;
  final String timestamp;
  final String painPoint;
  final String category;
  final int impactScore;
  final String sentiment;
  final String recommendation;

  Map<String, dynamic> toJson() => {
        'agentName': agentName,
        'timestamp': timestamp,
        'painPoint': painPoint,
        'category': category,
        'impactScore': impactScore,
        'sentiment': sentiment,
        'recommendation': recommendation,
      };
}

class SalesResponse {
  SalesResponse({
    required this.forecast,
    required this.conversionRate,
    required this.suggestion,
    this.agentName = 'Sales_AI',
  });

  final String agentName;
  final String forecast;
  final String conversionRate;
  final String suggestion;

  Map<String, dynamic> toJson() => {
        'agentName': agentName,
        'forecast': forecast,
        'conversionRate': conversionRate,
        'suggestion': suggestion,
      };
}

class StrategyResponse {
  StrategyResponse({
    required this.priority,
    required this.immediateAction,
    required this.confidence,
    this.agentName = 'Strategy_AI',
  });

  final String agentName;
  final String priority;
  final List<String> immediateAction;
  final int confidence;

  Map<String, dynamic> toJson() => {
        'agentName': agentName,
        'priority': priority,
        'immediateAction': immediateAction,
        'confidence': confidence,
      };
}
