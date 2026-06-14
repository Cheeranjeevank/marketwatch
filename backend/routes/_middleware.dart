import 'package:dart_frog/dart_frog.dart';

import 'package:backend/agents/marketing_agent.dart';
import 'package:backend/agents/product_agent.dart';
import 'package:backend/agents/sales_agent.dart';
import 'package:backend/agents/strategy_agent.dart';
import 'package:backend/services/forecasting_service.dart';
import 'package:backend/services/scraper_service.dart';
import 'package:backend/services/sentiment_service.dart';
import 'package:backend/services/strategy_service.dart';
import 'package:backend/services/tflite_service.dart';

final _scraperService = ScraperService();
final _tfliteService = TfLiteService();
final _sentimentService = SentimentService();
final _forecastingService = ForecastingService();
final _strategyService = StrategyService();

final _marketingAgent = MarketingAgent(
  _scraperService,
  _tfliteService,
  _sentimentService,
);

final _productAgent = ProductAgent(
  _tfliteService,
  _sentimentService,
);

final _salesAgent = SalesAgent(_forecastingService);
final _strategyAgent = StrategyAgent(_strategyService);

Handler middleware(Handler handler) {
  return handler
      .use(provider<MarketingAgent>((_) => _marketingAgent))
      .use(provider<ProductAgent>((_) => _productAgent))
      .use(provider<SalesAgent>((_) => _salesAgent))
      .use(provider<StrategyAgent>((_) => _strategyAgent));
}
