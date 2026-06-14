import '../models/response_models.dart';
import '../services/forecasting_service.dart';

class SalesAgent {
  SalesAgent(this.forecastingService);

  final ForecastingService forecastingService;

  Future<SalesResponse> analyze(
    int sentiment,
    int impactScore,
    int? historicalSales,
  ) async {
    
    // Multivariate Regression Model for Digital Marketing ROAS
    // X1 (Sentiment): Correlates to Ad Relevance Score (0.0 - 1.0)
    // X2 (Impact Score): Correlates to Bounce Rate / Friction (0.0 - 1.0)
    
    // Normalize independent variables
    double x1 = sentiment / 100.0;
    double x2 = impactScore / 100.0;
    
    // Regression Equation: ROAS = b0 + b1(X1) - b2(X2)
    double beta0 = 1.5; // Base ROAS is 1.5x
    double beta1 = 3.5; // High sentiment can add up to 3.5x ROAS
    double beta2 = 4.0; // High friction/bounce can subtract 4.0x ROAS
    
    double calculatedRoas = beta0 + (beta1 * x1) - (beta2 * x2);
    calculatedRoas = calculatedRoas.clamp(0.1, 8.0); // ROAS bounded between 0.1x and 8.0x
    
    // CAC Calculation (Inverse to ROAS)
    double baseCpa = 50.0; // Base CPA $50
    double cac = baseCpa / calculatedRoas;
    
    // Forecast Classification
    String forecast = 'Stable Margins';
    if (calculatedRoas < 1.0) forecast = 'Negative ROI - Capital Burn Detected';
    else if (calculatedRoas > 3.0) forecast = 'Highly Profitable - Scale Budget';
    
    // Tactical Suggestion based on Regression weights
    String suggestion = 'Maintain current daily budget allocations.';
    if (calculatedRoas < 1.0 && x2 > 0.6) {
      suggestion = 'Halt campaigns immediately. Landing page friction (x2) is destroying ROAS. CAC is \$${cac.toStringAsFixed(2)}.';
    } else if (calculatedRoas > 3.0 && x1 > 0.7) {
      suggestion = 'Increase daily ad spend by 30%. High relevance (x1) is driving a \$${cac.toStringAsFixed(2)} CAC.';
    } else if (x1 < 0.4) {
      suggestion = 'A/B Test new ad creatives. Low relevance score is suppressing ROAS.';
    }

    return SalesResponse(
      forecast: forecast,
      conversionRate: "${calculatedRoas.toStringAsFixed(2)}x ROAS",
      suggestion: suggestion,
    );
  }
}
