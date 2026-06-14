class ForecastingService {
  Map<String, String> generateForecast(
    int sentiment,
    int impactScore,
    int? historicalSales,
  ) {
    if (sentiment > 80 && impactScore < 50) {
      return {
        'forecast': 'Demand expected to increase by 14%',
        'conversionRate': '4.1%',
        'suggestion': 'Run limited-time bundle offer',
      };
    } else {
      return {
        'forecast': 'Demand expected to drop by 5%',
        'conversionRate': '2.4%',
        'suggestion': 'Increase ad spend and address product concerns',
      };
    }
  }
}
