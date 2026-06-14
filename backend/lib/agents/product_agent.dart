import '../models/response_models.dart';
import '../services/sentiment_service.dart';
import '../services/tflite_service.dart';

class ProductAgent {
  ProductAgent(this.tflite, this.sentimentService);

  final TfLiteService tflite;
  final SentimentService sentimentService;

  Future<ProductResponse> analyze(String transcript) async {
    final textLower = transcript.toLowerCase();
    
    double dotProductSum = 0.0;
    List<String> detectedFeatures = [];
    String? dominantCategory;
    
    // Pattern to category mapping based on user inputs
    final Map<String, Map<String, dynamic>> rules = {
      // 1. Battery Problems
      'battery drain': {'cat': 'Battery Problem', 'weight': 0.8},
      'not charging': {'cat': 'Battery Problem', 'weight': 0.9},
      'slow charging': {'cat': 'Battery Problem', 'weight': 0.6},
      'overcharging': {'cat': 'Battery Problem', 'weight': 0.7},
      'battery overheat': {'cat': 'Battery Problem', 'weight': 0.9},
      'battery swelling': {'cat': 'Battery Problem', 'weight': 1.0},
      'sudden shutdown': {'cat': 'Battery Problem', 'weight': 0.9},
      'percentage jumping': {'cat': 'Battery Problem', 'weight': 0.6},
      'standby drain': {'cat': 'Battery Problem', 'weight': 0.6},
      'health degradation': {'cat': 'Battery Problem', 'weight': 0.5},
      
      // 2. Performance Problems
      'running slow': {'cat': 'Performance Problem', 'weight': 0.7},
      'app lagging': {'cat': 'Performance Problem', 'weight': 0.6},
      'freezing': {'cat': 'Performance Problem', 'weight': 0.8},
      'random restart': {'cat': 'Performance Problem', 'weight': 0.9},
      'hanging': {'cat': 'Performance Problem', 'weight': 0.8},
      'high ram': {'cat': 'Performance Problem', 'weight': 0.5},
      'storage bottleneck': {'cat': 'Performance Problem', 'weight': 0.6},
      'background process': {'cat': 'Performance Problem', 'weight': 0.4},
      'slow boot': {'cat': 'Performance Problem', 'weight': 0.6},
      'touch delay': {'cat': 'Performance Problem', 'weight': 0.7},

      // 3. Display Problems
      'flickering': {'cat': 'Display Problem', 'weight': 0.8},
      'dead pixel': {'cat': 'Display Problem', 'weight': 0.7},
      'black screen': {'cat': 'Display Problem', 'weight': 1.0},
      'white screen': {'cat': 'Display Problem', 'weight': 1.0},
      'green line': {'cat': 'Display Problem', 'weight': 0.9},
      'pink line': {'cat': 'Display Problem', 'weight': 0.9},
      'burn-in': {'cat': 'Display Problem', 'weight': 0.8},
      'ghost touch': {'cat': 'Display Problem', 'weight': 0.9},
      'unresponsive touch': {'cat': 'Display Problem', 'weight': 0.9},
      'auto-brightness': {'cat': 'Display Problem', 'weight': 0.4},

      // 4. Network Problems
      'no signal': {'cat': 'Network Problem', 'weight': 0.9},
      'weak signal': {'cat': 'Network Problem', 'weight': 0.6},
      'call drop': {'cat': 'Network Problem', 'weight': 0.8},
      'mobile data': {'cat': 'Network Problem', 'weight': 0.7},
      'slow internet': {'cat': 'Network Problem', 'weight': 0.5},
      'sim card': {'cat': 'Network Problem', 'weight': 0.8},
      'roaming': {'cat': 'Network Problem', 'weight': 0.5},
      '5g': {'cat': 'Network Problem', 'weight': 0.4},
      'network switching': {'cat': 'Network Problem', 'weight': 0.5},
      'vpn': {'cat': 'Network Problem', 'weight': 0.4},

      // 5. Wi-Fi Problems
      'wi-fi': {'cat': 'Wi-Fi Problem', 'weight': 0.7},
      'wifi': {'cat': 'Wi-Fi Problem', 'weight': 0.7},
      'hotspot': {'cat': 'Wi-Fi Problem', 'weight': 0.6},
      'dns': {'cat': 'Wi-Fi Problem', 'weight': 0.5},

      // 6. Bluetooth Problems
      'bluetooth': {'cat': 'Bluetooth Problem', 'weight': 0.6},
      'pairing': {'cat': 'Bluetooth Problem', 'weight': 0.6},

      // 7. Audio Problems
      'no sound': {'cat': 'Audio Problem', 'weight': 0.9},
      'distorted sound': {'cat': 'Audio Problem', 'weight': 0.7},
      'speaker': {'cat': 'Audio Problem', 'weight': 0.7},
      'microphone': {'cat': 'Audio Problem', 'weight': 0.8},
      'earphone': {'cat': 'Audio Problem', 'weight': 0.6},

      // 8. Camera Problems
      'camera': {'cat': 'Camera Problem', 'weight': 0.8},
      'blurry': {'cat': 'Camera Problem', 'weight': 0.6},
      'autofocus': {'cat': 'Camera Problem', 'weight': 0.6},
      'video recording': {'cat': 'Camera Problem', 'weight': 0.8},

      // 9. Storage Problems
      'storage full': {'cat': 'Storage Problem', 'weight': 0.8},
      'corrupted file': {'cat': 'Storage Problem', 'weight': 0.9},
      'sd card': {'cat': 'Storage Problem', 'weight': 0.7},
      'cache overload': {'cat': 'Storage Problem', 'weight': 0.4},
      'insufficient storage': {'cat': 'Storage Problem', 'weight': 0.8},

      // 10. Software Problems
      'crash': {'cat': 'Software Problem', 'weight': 0.8},
      'update fail': {'cat': 'Software Problem', 'weight': 0.8},
      'boot loop': {'cat': 'Software Problem', 'weight': 1.0},
      'malware': {'cat': 'Software Problem', 'weight': 1.0},
      'virus': {'cat': 'Software Problem', 'weight': 1.0},
      'permission': {'cat': 'Software Problem', 'weight': 0.5},

      // 11. Security Problems
      'unauthorized': {'cat': 'Security Problem', 'weight': 1.0},
      'phishing': {'cat': 'Security Problem', 'weight': 1.0},
      'data theft': {'cat': 'Security Problem', 'weight': 1.0},
      'spyware': {'cat': 'Security Problem', 'weight': 1.0},
      'fake app': {'cat': 'Security Problem', 'weight': 0.9},
      'password compromise': {'cat': 'Security Problem', 'weight': 1.0},
      'sim swap': {'cat': 'Security Problem', 'weight': 1.0},
      'privacy leak': {'cat': 'Security Problem', 'weight': 1.0},

      // 12. Sensor Problems
      'fingerprint': {'cat': 'Sensor Problem', 'weight': 0.8},
      'face unlock': {'cat': 'Sensor Problem', 'weight': 0.8},
      'proximity': {'cat': 'Sensor Problem', 'weight': 0.6},
      'accelerometer': {'cat': 'Sensor Problem', 'weight': 0.6},
      'gyroscope': {'cat': 'Sensor Problem', 'weight': 0.6},
      'compass': {'cat': 'Sensor Problem', 'weight': 0.5},

      // 13. Hardware Problems
      'water damage': {'cat': 'Physical Hardware Problem', 'weight': 1.0},
      'physical damage': {'cat': 'Physical Hardware Problem', 'weight': 1.0},
      'bent': {'cat': 'Physical Hardware Problem', 'weight': 0.9},
      'broken': {'cat': 'Physical Hardware Problem', 'weight': 0.8},
      'antenna': {'cat': 'Physical Hardware Problem', 'weight': 0.8},

      // 14. Charging Port Problems
      'usb port': {'cat': 'Charging Port Problem', 'weight': 0.8},
      'charging port': {'cat': 'Charging Port Problem', 'weight': 0.8},
      'debris': {'cat': 'Charging Port Problem', 'weight': 0.5},

      // 15. Gaming Problems
      'fps': {'cat': 'Gaming Problem', 'weight': 0.6},
      'gaming': {'cat': 'Gaming Problem', 'weight': 0.5},
      'latency': {'cat': 'Gaming Problem', 'weight': 0.6},

      // 16. AI Predictive
      'predict': {'cat': 'AI Predictive Issue', 'weight': 0.5},
      'future': {'cat': 'AI Predictive Issue', 'weight': 0.5},
      'estimation': {'cat': 'AI Predictive Issue', 'weight': 0.5},
      'anomaly': {'cat': 'AI Predictive Issue', 'weight': 0.8},

      // Amazon FBA / E-commerce Fallback
      'return': {'cat': 'FBA Returns & Quality', 'weight': 0.8},
      'damaged': {'cat': 'FBA Returns & Quality', 'weight': 0.85},
      'fake': {'cat': 'Listing Hijack / Fraud', 'weight': 0.9},
      'hijack': {'cat': 'Listing Hijack / Fraud', 'weight': 0.95},
      'buybox': {'cat': 'Listing Hijack / Fraud', 'weight': 0.9},
      'fba': {'cat': 'Amazon FBA Ops', 'weight': 0.6},
      'fee': {'cat': 'Amazon FBA Ops', 'weight': 0.5},
      'lost': {'cat': 'Amazon FBA Ops', 'weight': 0.75},
      'overheated': {'cat': 'Safety & Quality Hazard', 'weight': 0.9},
      'overheating': {'cat': 'Safety & Quality Hazard', 'weight': 0.9},
      'heat': {'cat': 'Safety & Quality Hazard', 'weight': 0.7},
      'fire': {'cat': 'Safety & Quality Hazard', 'weight': 1.0},
      'exploded': {'cat': 'Safety & Quality Hazard', 'weight': 1.0},
      'melted': {'cat': 'Safety & Quality Hazard', 'weight': 0.95},
    };

    for (var entry in rules.entries) {
      if (textLower.contains(entry.key)) {
        dotProductSum += entry.value['weight'];
        detectedFeatures.add(entry.key);
        dominantCategory = entry.value['cat'];
      }
    }
    
    // Non-linear Sigmoid Activation for Impact Score
    double baseFriction = 30.0;
    double calculatedImpact = baseFriction + (dotProductSum * 20.0);
    int impactScore = calculatedImpact.clamp(0, 100).round();
    
    String category = dominantCategory ?? 'Listing & Feedback';

    String painPoint = detectedFeatures.isNotEmpty 
        ? 'Detected issues: ${detectedFeatures.toSet().join(", ")}'
        : 'No specific operational issues detected';

    String sentiment = impactScore > 75 ? 'Critical Seller Risk' : (impactScore > 50 ? 'Moderate Issue' : 'Operations Normal');
    
    String recommendation = 'Monitor seller metrics and feedback.';
    if (category == 'Listing Hijack / Fraud') recommendation = 'IMMEDIATE ACTION: File IP infringement report and contact Amazon Brand Registry.';
    else if (category == 'Safety & Quality Hazard' || category == 'Physical Hardware Problem' || category == 'Battery Problem') recommendation = 'URGENT: Halt sales immediately and investigate batch for thermal/safety defects.';
    else if (category == 'FBA Returns & Quality') recommendation = 'Inspect returned units. Pause FBA shipments if defect rate exceeds 5%.';
    else if (category == 'Security Problem') recommendation = 'URGENT: Implement security patches and force password resets.';
    else if (impactScore > 60) recommendation = 'Investigate Voice of the Customer dashboard for sudden spikes in negative metrics.';
    else if (impactScore > 40) recommendation = 'Review recent listing changes or price updates.';

    if (impactScore > 50) {
      if (category == 'Battery Problem' || category == 'Safety & Quality Hazard') {
        recommendation += ' | SENIOR DEV TIP: Profile PMIC thermal throttling, optimize background wake-locks, and enforce stricter sleep state transitions.';
      } else if (category == 'Performance Problem') {
        recommendation += ' | SENIOR DEV TIP: Run memory profiler to detect GC thrashing, optimize main thread operations, and offload to workers.';
      } else if (category == 'Display Problem') {
        recommendation += ' | SENIOR DEV TIP: Audit display driver VSYNC timing, inspect PWM dimming bugs, and recalibrate OLED voltage parameters.';
      } else if (category == 'Network Problem' || category == 'Wi-Fi Problem' || category == 'Bluetooth Problem') {
        recommendation += ' | SENIOR DEV TIP: Review modem baseband firmware, optimize antenna diversity algorithms, and patch radio HAL interfaces.';
      } else if (category == 'Storage Problem') {
        recommendation += ' | SENIOR DEV TIP: Check storage controller wear-leveling algorithms, implement better file system journaling, and auto-clear orphaned cache.';
      } else if (category == 'Software Problem') {
        recommendation += ' | SENIOR DEV TIP: Analyze crash dumps via Crashlytics, patch kernel panics, and write unit tests covering race conditions.';
      } else if (category == 'Security Problem') {
        recommendation += ' | SENIOR DEV TIP: Audit encryption key lifecycle (Keystore/Secure Enclave), patch root-escalation vulnerabilities, and enforce certificate pinning.';
      } else if (category == 'Audio Problem') {
        recommendation += ' | SENIOR DEV TIP: Debug DSP audio routing matrices, check ADC/DAC clipping thresholds, and update ALSA configurations.';
      } else if (category == 'Camera Problem') {
        recommendation += ' | SENIOR DEV TIP: Review ISP pipeline latency, debug autofocus actuator firmware, and fix buffer overflow in camera HAL.';
      } else {
        recommendation += ' | SENIOR DEV TIP: Setup comprehensive remote telemetry, aggregate device logs, and conduct root-cause analysis (RCA) on the affected subsystem.';
      }
    }

    return ProductResponse(
      timestamp: DateTime.now().toIso8601String(),
      painPoint: painPoint,
      category: category,
      impactScore: impactScore,
      sentiment: sentiment,
      recommendation: recommendation,
    );
  }
}
