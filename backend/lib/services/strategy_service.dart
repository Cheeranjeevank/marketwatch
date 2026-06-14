class StrategyService {
  Map<String, dynamic> computeStrategy(
    String marketingSummary,
    String productPainPoint,
    String salesForecast,
  ) {
    if (marketingSummary.toLowerCase().contains('dropping') ||
        productPainPoint.toLowerCase().contains('heating') ||
        salesForecast.toLowerCase().contains('decreasing')) {
      return {
        'priority': 'Critical',
        'confidence': 95,
        'immediateAction': [
          'Pause marketing campaigns for 48 hours',
          'Release performance patch',
          'Relaunch with stability-focused messaging',
        ],
      };
    } else {
      return {
        'priority': 'Normal',
        'confidence': 88,
        'immediateAction': [
          'Continue current marketing cadence',
          'Monitor product metrics',
        ],
      };
    }
  }
}
