import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'ai_service.dart';

void main() {
  runApp(const MarketWatchApp());
}

class MarketWatchApp extends StatelessWidget {
  const MarketWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'marketwatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1), // Indigo
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Deep Slate
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF10B981), // Emerald
          surface: Color(0xFF1E293B), // Card Slate
          error: Color(0xFFEF4444), // Rose
          outline: Color(0xFF334155),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B).withOpacity(0.8),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155), width: 1.2),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
          titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 13.5, color: Color(0xFFCBD5E1)),
          bodySmall: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        ),
      ),
      home: const AICockpitTabsPage(),
    );
  }
}

class AICockpitTabsPage extends StatefulWidget {
  const AICockpitTabsPage({super.key});

  @override
  State<AICockpitTabsPage> createState() => _AICockpitTabsPageState();
}

class _AICockpitTabsPageState extends State<AICockpitTabsPage> {
  int _currentIndex = 0;
  final AIService _aiService = AIService();
  String _statusMessage = "Initializing AI Swarm Models...";

  // Global Mock States shared across tabs
  List<Map<String, dynamic>> campaigns = [];
  List<Map<String, dynamic>> reviews = [];
  List<Map<String, dynamic>> leads = [];
  List<Map<String, dynamic>> recommendations = [];
  List<Map<String, String>> systemLogs = [];

  @override
  void initState() {
    super.initState();
    _initAI();
    _loadInitialMockData();
  }

  Future<void> _initAI() async {
    await _aiService.init();
    setState(() {
      if (_aiService.isLoaded) {
        final count = 4 - _aiService.loadErrors.length;
        _statusMessage = "$count/4 TFLite Agent Classifiers Loaded Successfully";
      } else {
        _statusMessage = "Running in high-fidelity rule-based engine modes";
      }
    });
  }

  void _loadInitialMockData() {
    campaigns = [
      {
        "id": "c1",
        "competitor": "B08F7PTF54",
        "title": "Exact Match - Wireless Earbuds",
        "channel": "Amazon Search",
        "spent": 1500,
        "clicks": 245,
        "sentiment": "Profitable",
        "impact": "High",
        "date": "Today"
      },
      {
        "id": "c2",
        "competitor": "B08F7PTF55",
        "title": "Auto Campaign - Headphones",
        "channel": "Amazon Sponsored Products",
        "spent": 850,
        "clicks": 92,
        "sentiment": "Losing Money",
        "impact": "Medium",
        "date": "Today"
      },
      {
        "id": "c3",
        "competitor": "B08F7PTF56",
        "title": "Retargeting - Audio",
        "channel": "Amazon Sponsored Display",
        "spent": 4500,
        "clicks": 1230,
        "sentiment": "Highly Profitable",
        "impact": "Critical",
        "date": "Yesterday"
      }
    ];

    reviews = [
      {
        "id": "r1",
        "platform": "Amazon",
        "rating": 2,
        "content": "The box arrived completely crushed and the product was fake. I am returning this.",
        "sentiment": "Negative",
        "gap": "Counterfeit Product",
        "user": "Verified Buyer",
        "recommendation": "IMMEDIATE ACTION: File IP infringement report and contact Amazon Brand Registry."
      },
      {
        "id": "r2",
        "platform": "Amazon",
        "rating": 3,
        "content": "Overall the sound quality is decent, but the battery dies too quickly.",
        "sentiment": "Neutral",
        "gap": "Battery Issue",
        "user": "Verified Buyer"
      },
      {
        "id": "r3",
        "platform": "Amazon",
        "rating": 5,
        "content": "Amazing product! Exactly as described in the listing.",
        "sentiment": "Positive",
        "gap": "None",
        "user": "Verified Buyer"
      }
    ];

    leads = [
      {
        "id": "l1",
        "company": "ASIN: B08F7PTF54",
        "signal": "High ACoS detected during Diwali sale.",
        "role": "Electronics",
        "value": 2500,
        "confidence": 88,
        "status": "Losing Money"
      },
      {
        "id": "l2",
        "company": "ASIN: B08F7PTF55",
        "signal": "Excellent profit margins on exact match keywords.",
        "role": "Accessories",
        "value": 4800,
        "confidence": 94,
        "status": "Profitable"
      }
    ];

    recommendations = [
      {
        "id": "rec1",
        "title": "Stop Broad Match Ads",
        "description": "Stop your generic Amazon Ads! You are spending too much money for too few sales.",
        "confidence": 95,
        "impact": "High"
      },
      {
        "id": "rec2",
        "title": "Report Listing Hijacker",
        "description": "Alert: Someone is selling fake copies of your product! Report them to Amazon immediately.",
        "confidence": 92,
        "impact": "Critical"
      }
    ];

    systemLogs = [
      {"agent": "marketing", "title": "Marketing AI", "text": "Scraped 4 active competitor campaigns from Twitter feed.", "time": "2m ago"},
      {"agent": "sales", "title": "Sales AI", "text": "Scored new lead TechCorp Solutions with 88% confidence.", "time": "12m ago"},
      {"agent": "product", "title": "Product AI", "text": "Flagged G2 review regarding reporting export performance gaps.", "time": "45m ago"}
    ];
  }

  void _addCampaign(Map<String, dynamic> c) {
    setState(() {
      campaigns.insert(0, c);
      systemLogs.insert(0, {
        "agent": "marketing",
        "title": "Marketing AI",
        "text": "Simulated new ad detection: ${c['title']} by ${c['competitor']}",
        "time": "Just now"
      });
    });
  }

  void _addReview(Map<String, dynamic> r) {
    setState(() {
      reviews.insert(0, r);
      systemLogs.insert(0, {
        "agent": "product",
        "title": "Product AI",
        "text": "Acoustic review transcription logged: ${r['gap']}",
        "time": "Just now"
      });
    });
  }

  void _addLead(Map<String, dynamic> l) {
    setState(() {
      leads.insert(0, l);
      systemLogs.insert(0, {
        "agent": "sales",
        "title": "Sales AI",
        "text": "Qualified lead ${l['company']} valued at \$${l['value']}",
        "time": "Just now"
      });
    });
  }

  void _addLog(String agent, String title, String text) {
    setState(() {
      systemLogs.insert(0, {
        "agent": agent,
        "title": title,
        "text": text,
        "time": "Just now"
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      OverviewTab(
        campaignsCount: campaigns.length,
        reviewsCount: reviews.length,
        leadsCount: leads.length,
        recommendationsCount: recommendations.length,
        logs: systemLogs,
        onFileProcessed: (filename, rowCount) {
          setState(() {
            // Simulate massive data ingestion for visual effect
            for (int i = 0; i < 12; i++) {
              campaigns.insert(0, {"id": "sync_c$i", "competitor": "RivalBrand $i", "title": "Q3 Sponsored Display", "channel": "Amazon", "spent": 450, "impact": "Medium"});
            }
            for (int i = 0; i < 85; i++) {
              reviews.insert(0, {"id": "sync_r$i", "platform": "Amazon", "rating": 5, "content": "Great product!", "sentiment": "Positive", "gap": "None", "user": "Verified"});
            }
            for (int i = 0; i < 6; i++) {
              leads.insert(0, {"id": "sync_l$i", "company": "B08F7PTF$i", "signal": "Stable ad spend detected", "role": "Home", "value": 1500, "confidence": 85, "status": "Warm"});
            }
            for (int i = 0; i < 3; i++) {
              recommendations.insert(0, {"id": "sync_rec$i", "title": "Lower ACoS on generic keywords", "description": "Found high ACoS on generic search terms from the recent sync.", "confidence": 92, "impact": "High"});
            }
            systemLogs.insert(0, {
              "agent": "system",
              "title": "System Swarm",
              "text": "Successfully ingested $rowCount rows from $filename. Created 3 new AI strategies.",
              "time": "Just now"
            });
          });
        },
      ),
      MarketingTab(
        aiService: _aiService,
        campaigns: campaigns,
        onCampaignSimulated: _addCampaign,
      ),
      ProductTab(
        aiService: _aiService,
        reviews: reviews,
        onReviewSimulated: _addReview,
      ),
      SalesTab(
        aiService: _aiService,
        leads: leads,
        onLeadSimulated: _addLead,
        onQualify: (id) {
          setState(() {
            leads.removeWhere((l) => l["id"] == id);
          });
        },
      ),
      StrategyTab(
        aiService: _aiService,
        recommendations: recommendations,
        reviews: reviews,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'marketwatch',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            )
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF818CF8)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Swarm Telemetry Resynced"),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          )
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: const Color(0xFF6366F1), // Indigo
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Ads'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Feedback'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Profit'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Strategy'),
        ],
      ),
    );
  }
}

// ==================== TAB 0: OVERVIEW TAB ====================
class OverviewTab extends StatefulWidget {
  final int campaignsCount;
  final int reviewsCount;
  final int leadsCount;
  final int recommendationsCount;
  final List<Map<String, String>> logs;
  final Function(String, int) onFileProcessed;

  const OverviewTab({
    super.key,
    required this.campaignsCount,
    required this.reviewsCount,
    required this.leadsCount,
    required this.recommendationsCount,
    required this.logs,
    required this.onFileProcessed,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  bool _isProcessing = false;
  String _uploadStatus = "Idle. Ready for CSV/JSON";
  String? _selectedFilename;

  Future<void> _simulateUpload() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select File to Process'),
          backgroundColor: const Color(0xFF1E293B),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('customer_sentiment_sheet_2026.csv', style: TextStyle(color: Colors.white, fontSize: 13)),
                onTap: () => Navigator.pop(context, 'customer_sentiment_sheet_2026.csv'),
              ),
              ListTile(
                leading: const Icon(Icons.data_object, color: Colors.blue),
                title: const Text('q3_product_feedback_logs.json', style: TextStyle(color: Colors.white, fontSize: 13)),
                onTap: () => Navigator.pop(context, 'q3_product_feedback_logs.json'),
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Colors.orange),
                title: const Text('sales_forecast_raw.txt', style: TextStyle(color: Colors.white, fontSize: 13)),
                onTap: () => Navigator.pop(context, 'sales_forecast_raw.txt'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedFilename = selected;
        _uploadStatus = "File Loaded. Ready to process.";
      });
    }
  }

  void _simulateProcessing() {
    setState(() {
      _isProcessing = true;
      _uploadStatus = "Connecting to Amazon API...";
    });

    Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _uploadStatus = "Fetching 30-day Sales & Ads...";
      });
      Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _uploadStatus = "Synced!";
          widget.onFileProcessed("Amazon Seller Central Sync", 1420);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Glowing Network Status Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0xFF10B981), blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Amazon Connection Status: Active & Synced",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid (2x2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _buildStatCard("Total Ad Campaigns", widget.campaignsCount.toString(), "Marketing Agent", Colors.teal, Icons.campaign),
                _buildStatCard("Customer Feedback", widget.reviewsCount.toString(), "Product Agent", Colors.orange, Icons.web),
                _buildStatCard("Profit Margin", widget.leadsCount.toString(), "Sales Agent", Colors.green, Icons.monetization_on),
                _buildStatCard("Business Advice", widget.recommendationsCount.toString(), "Strategy Agent", Colors.amber, Icons.insights),
              ],
            ),
            const SizedBox(height: 20),

            // Ingestion Box
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Live Data Sync",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: Text(
                              _uploadStatus, 
                              style: const TextStyle(fontSize: 9, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155), width: 1, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.sync, size: 48, color: Color(0xFF10B981)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _isProcessing ? null : _simulateProcessing,
                            child: _isProcessing
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("Sync Amazon Data", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Trending Amazon Devices
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Trending Amazon Devices", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                Text("Updated just now", style: TextStyle(fontSize: 10, color: Colors.tealAccent)),
              ],
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final List<Map<String, dynamic>> trendingItems = [
                  {
                    "name": "Samsung Galaxy S24 Ultra",
                    "category": "Smartphones",
                    "trend": "+42% demand",
                    "icon": Icons.smartphone,
                    "color": Colors.blueAccent
                  },
                  {
                    "name": "Apple iPhone 15 Pro",
                    "category": "Smartphones",
                    "trend": "+28% demand",
                    "icon": Icons.phone_iphone,
                    "color": Colors.white
                  },
                  {
                    "name": "Amazon Echo Show 10",
                    "category": "Smart Home",
                    "trend": "+15% demand",
                    "icon": Icons.speaker,
                    "color": Colors.cyanAccent
                  },
                  {
                    "name": "Sony WH-1000XM5",
                    "category": "Audio",
                    "trend": "+35% demand",
                    "icon": Icons.headphones,
                    "color": Colors.deepPurpleAccent
                  }
                ];
                final item = trendingItems[idx];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item["color"].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item["icon"], color: item["color"], size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['category']!,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['trend']!,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String val, String subtitle, Color accentColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor)),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

// ==================== TAB 1: MARKETING TAB ====================
class MarketingTab extends StatefulWidget {
  final AIService aiService;
  final List<Map<String, dynamic>> campaigns;
  final Function(Map<String, dynamic>) onCampaignSimulated;

  const MarketingTab({
    super.key,
    required this.aiService,
    required this.campaigns,
    required this.onCampaignSimulated,
  });

  @override
  State<MarketingTab> createState() => _MarketingTabState();
}

class _MarketingTabState extends State<MarketingTab> {
  final TextEditingController _textController = TextEditingController(
    text: "Acme Corp announced amazing Organic growth. Love features, yes excellent stability!"
  );
  final TextEditingController _urlController = TextEditingController(
    text: "https://amazon.in/dp/B08F7PTF54"
  );
  final TextEditingController _competitorController = TextEditingController(
    text: "B08F7PTF54 (Acme Corp)"
  );
  String _selectedPlatform = "Amazon US";
  bool _isScraping = false;
  String _scrapeLog = "Awaiting scraping trigger...";
  
  // Results
  bool _hasResult = false;
  int _sentiment = 50;
  int _urgency = 50;
  double _impactScore = 0.5;
  String _summary = "";
  String _recommendation = "";
  String _jsonPayload = "";
  double _rawTfliteOutput = 0.5;

  // Dynamic Dashboard Metrics (real values from ML engine)
  int _dashboardSpend = 24500;
  double _dashboardAcos = 32.4;
  double _dashboardRoas = 3.1;
  int _dashboardClicks = 1420;
  double _profitMargin = 0.0;   // real computed profit margin %
  double _breakevenAcos = 0.0;  // breakeven ACoS threshold
  int _estimatedProfit = 0;     // ₹ estimated profit after ad spend
  String _campaignHealth = "PENDING"; // EXCELLENT / GOOD / WARNING / CRITICAL

  Future<void> _simulateCameraScan() async {
    setState(() {
      _isScraping = true;
      _scrapeLog = "Opening camera...";
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image == null) {
        setState(() {
          _isScraping = false;
          _scrapeLog = "Camera scan cancelled.";
        });
        return;
      }

      setState(() {
        _scrapeLog = "Processing image OCR...";
      });

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      await textRecognizer.close();

      setState(() {
        if (recognizedText.text.trim().isEmpty) {
          _scrapeLog = "No text found in image.";
          _textController.text = "";
        } else {
          _textController.text = recognizedText.text;
          _scrapeLog = "OCR Scan complete. Found text.";
        }
        _isScraping = false;
      });
    } catch (e) {
      setState(() {
        _isScraping = false;
        _scrapeLog = "Error during camera scan: $e";
      });
    }
  }

  void _simulateLinkScrape() async {
    final urlText = _urlController.text.trim();
    if (urlText.isEmpty) return;

    setState(() {
      _isScraping = true;
      _scrapeLog = "Connecting to $urlText...\nParsing DOM & Metadata...";
    });

    try {
      final url = Uri.parse(urlText.startsWith('http') ? urlText : 'https://$urlText');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        
        // Extract Title
        String title = document.querySelector('title')?.text.trim() ?? '';
        
        // Extract Meta Description
        String description = '';
        final metaTags = document.querySelectorAll('meta');
        for (var meta in metaTags) {
          if (meta.attributes['name']?.toLowerCase() == 'description' || 
              meta.attributes['property']?.toLowerCase() == 'og:description') {
            description = meta.attributes['content']?.trim() ?? '';
            break;
          }
        }
        
        // Extract H1 Headers
        String h1Text = document.querySelectorAll('h1').map((e) => e.text.trim()).join(' | ');

        // Extract Paragraphs
        String paragraphs = document.querySelectorAll('p')
            .map((e) => e.text.trim())
            .where((e) => e.isNotEmpty && e.length > 20)
            .take(5)
            .join(' ');

        // Compile intelligent buffer
        StringBuffer buffer = StringBuffer();
        if (title.isNotEmpty) buffer.writeln("Title: $title");
        if (description.isNotEmpty) buffer.writeln("Description: $description");
        if (h1Text.isNotEmpty) buffer.writeln("Headers: $h1Text");
        if (paragraphs.isNotEmpty) buffer.writeln("\nContent: $paragraphs");

        String body = buffer.toString().trim();

        // Limit size to prevent UI freeze
        if (body.length > 800) {
          body = "${body.substring(0, 800)}...";
        }

        setState(() {
          _textController.text = body.isEmpty ? "No readable text found at URL." : body;
          _scrapeLog = "Scrape complete. Extracted metadata and semantic text.";
          _isScraping = false;
        });
      } else {
        setState(() {
          _textController.text = "Failed to load URL: Status ${response.statusCode}";
          _scrapeLog = "Error during scraping.";
          _isScraping = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _textController.text = "Failed to fetch URL. Ensure it is accessible.";
        _scrapeLog = "Exception: $e";
        _isScraping = false;
      });
    }
  }

  Future<void> _runClassifier() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isScraping = true;
      _scrapeLog = "Loading text...\nChecking Amazon data...\nAnalyzing profitability...";
    });

    final res = await widget.aiService.analyzeText(
      text: text,
      agentType: "marketing",
      trendingPlatform: _selectedPlatform,
      competitor: _competitorController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _hasResult = true;
      _sentiment = res.sentiment.round();
      _urgency = res.urgency.round();
      _impactScore = res.impactScore;
      _recommendation = res.recommendation;
      _summary = res.status == "Error" ? "Backend connection failed." : res.recommendation;
      
      // Update metrics from real ML-computed PPC values
      if (res.status != "Error") {
        _dashboardRoas    = GlobalTelemetry.roasEstimate;
        _dashboardAcos    = GlobalTelemetry.acosEstimate;
        _dashboardSpend   = GlobalTelemetry.spendEstimate;
        _dashboardClicks  = GlobalTelemetry.clicksEstimate;

        // Profit Margin = (RoAS - 1) / RoAS * 100
        _profitMargin     = ((_dashboardRoas - 1.0) / _dashboardRoas * 100).clamp(0, 85);
        // Breakeven ACoS corresponds to Gross Product Margin (Standard Amazon IN ~35%)
        _breakevenAcos    = 35.0;
        // Estimated profit = Spend * (RoAS - 1) - fixed costs proxy
        _estimatedProfit  = (_dashboardSpend * (_dashboardRoas - 1.0)).round();

        // Campaign health label based on ACoS vs Breakeven
        if (_dashboardAcos < _breakevenAcos * 0.6) {
          _campaignHealth = "EXCELLENT";
        } else if (_dashboardAcos < _breakevenAcos * 0.85) {
          _campaignHealth = "GOOD";
        } else if (_dashboardAcos < _breakevenAcos) {
          _campaignHealth = "WARNING";
        } else {
          _campaignHealth = "CRITICAL";
        }
      }

      _rawTfliteOutput = _sentiment / 100.0;
      _isScraping = false;
      _scrapeLog = res.status == "Error" ? "Failed to reach backend." : "Analysis completed via backend AI engine.";
    });
  }

  void _simulateNewAdDialog() {
    String comp = "Acme Corp";
    String title = "Next-Gen Integrations";
    String chan = "LinkedIn";
    int spent = 12000;
    int clicks = 1800;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("Analyze Competitor Ads"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: comp,
                  decoration: const InputDecoration(labelText: "Competitor"),
                  items: const [
                    DropdownMenuItem(value: "Acme Corp", child: Text("Acme Corp")),
                    DropdownMenuItem(value: "Initech", child: Text("Initech")),
                    DropdownMenuItem(value: "Hooli", child: Text("Hooli")),
                  ],
                  onChanged: (val) { if (val != null) comp = val; },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Headline"),
                  controller: TextEditingController(text: title),
                  onChanged: (val) => title = val,
                ),
                DropdownButtonFormField<String>(
                  value: chan,
                  decoration: const InputDecoration(labelText: "Channel"),
                  items: const [
                    DropdownMenuItem(value: "LinkedIn", child: Text("LinkedIn")),
                    DropdownMenuItem(value: "Google Search", child: Text("Google Search")),
                    DropdownMenuItem(value: "YouTube", child: Text("YouTube")),
                    DropdownMenuItem(value: "Twitter / X", child: Text("Twitter / X")),
                  ],
                  onChanged: (val) { if (val != null) chan = val; },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Est. Spend"),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: spent.toString()),
                  onChanged: (val) => spent = int.tryParse(val) ?? 0,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Clicks"),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: clicks.toString()),
                  onChanged: (val) => clicks = int.tryParse(val) ?? 0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                double cpc = clicks > 0 ? (spent / clicks) : spent.toDouble();
                String impactVal;
                String sentimentVal;
                if (cpc > 15 || spent > 20000) {
                  impactVal = "Critical";
                  sentimentVal = "Negative";
                } else if (cpc < 5 && clicks > 100) {
                  impactVal = "Good";
                  sentimentVal = "Positive";
                } else {
                  impactVal = "Normal";
                  sentimentVal = "Mixed";
                }

                widget.onCampaignSimulated({
                  "id": "c" + (widget.campaigns.length + 1).toString(),
                  "competitor": comp,
                  "title": title,
                  "channel": chan,
                  "spent": spent,
                  "clicks": clicks,
                  "sentiment": sentimentVal,
                  "impact": impactVal,
                  "date": "2026-06-13"
                });
                Navigator.pop(ctx);
              },
              child: const Text("Simulate"),
            ),
          ],
        );
      },
    );
  }

  // ─── Health colour helper ─────────────────────────────────────────────────
  Color get _healthColor {
    switch (_campaignHealth) {
      case "EXCELLENT": return const Color(0xFF10B981);
      case "GOOD":      return const Color(0xFF34D399);
      case "WARNING":   return const Color(0xFFF59E0B);
      case "CRITICAL":  return const Color(0xFFEF4444);
      default:          return const Color(0xFF64748B);
    }
  }

  IconData get _healthIcon {
    switch (_campaignHealth) {
      case "EXCELLENT": return Icons.trending_up;
      case "GOOD":      return Icons.check_circle_outline;
      case "WARNING":   return Icons.warning_amber;
      case "CRITICAL":  return Icons.cancel;
      default:          return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── SECTION 1: Live PPC Profit Dashboard ─────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bar_chart_rounded, color: Color(0xFF38BDF8), size: 18),
                      const SizedBox(width: 8),
                      const Text("Live Campaign Profitability",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                      const Spacer(),
                      // Campaign health badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _healthColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _healthColor.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_healthIcon, size: 12, color: _healthColor),
                            const SizedBox(width: 4),
                            Text(_campaignHealth,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _healthColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Row 1: Spend + ACoS + RoAS + Clicks
                  Row(
                    children: [
                      Expanded(child: _buildProfitCard("AD SPEND", "₹${_dashboardSpend.toLocaleString()}", Icons.account_balance_wallet, Colors.white)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProfitCard("ACoS", "${_dashboardAcos.toStringAsFixed(1)}%",
                          Icons.percent, _dashboardAcos > _breakevenAcos ? const Color(0xFFEF4444) : const Color(0xFFF59E0B))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProfitCard("RoAS", "${_dashboardRoas.toStringAsFixed(2)}x",
                          Icons.show_chart, _dashboardRoas >= 3.0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProfitCard("CLICKS", _dashboardClicks.toString(), Icons.ads_click, Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 2: Profit Margin + Breakeven ACoS + Estimated Profit
                  if (_hasResult) Row(
                    children: [
                      Expanded(child: _buildProfitCard("PROFIT MARGIN", "${_profitMargin.toStringAsFixed(1)}%",
                          Icons.savings, _profitMargin > 30 ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProfitCard("BREAKEVEN ACoS", "${_breakevenAcos.toStringAsFixed(1)}%",
                          Icons.balance, const Color(0xFF38BDF8))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildProfitCard("EST. PROFIT", "₹${_estimatedProfit.toLocaleString()}",
                          Icons.currency_rupee, _estimatedProfit > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── SECTION 2: Ad Analyzer Input ──────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Analyze Competitor Ads",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal)),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.search, size: 14),
                          label: const Text("+ Competitor", style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: _simulateNewAdDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedPlatform,
                      decoration: const InputDecoration(
                          labelText: "Marketplace / Platform", border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: "Amazon IN", child: Text("🇮🇳  Amazon India")),
                        DropdownMenuItem(value: "Amazon US", child: Text("🇺🇸  Amazon US")),
                        DropdownMenuItem(value: "Amazon UK", child: Text("🇬🇧  Amazon UK")),
                        DropdownMenuItem(value: "Flipkart",  child: Text("🛒  Flipkart")),
                        DropdownMenuItem(value: "Meesho",    child: Text("🛍  Meesho")),
                        DropdownMenuItem(value: "Instagram", child: Text("📸  Instagram")),
                        DropdownMenuItem(value: "Facebook",  child: Text("📘  Facebook")),
                        DropdownMenuItem(value: "WhatsApp",  child: Text("💬  WhatsApp Business")),
                        DropdownMenuItem(value: "YouTube",   child: Text("▶️  YouTube")),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPlatform = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _competitorController,
                      decoration: const InputDecoration(
                          labelText: "Competitor ASIN / Brand Name",
                          hintText: "e.g. B08F7PTF54 or BoAt Audio",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business_center)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                          labelText: "Competitor Product Link (optional)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── SECTION 3: Ad Text Input ──────────────────────────────────
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Paste Competitor Ad / Campaign Description",
                hintText: "e.g. ACOS is high, sales dropped this month, organic rank lost...",
                border: OutlineInputBorder(),
                fillColor: Color(0xFF1E293B),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),

            // ── RUN CLASSIFIER BUTTON ─────────────────────────────────────
            ElevatedButton.icon(
              icon: _isScraping
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.bolt, size: 18),
              label: Text(_isScraping ? "ANALYZING..." : "RUN PROFIT ANALYSIS",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isScraping ? null : _runClassifier,
            ),
            const SizedBox(height: 12),

            // ── STATUS LOG ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Icon(Icons.terminal, size: 13, color: const Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _scrapeLog,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── SECTION 4: AI Result Cards ────────────────────────────────
            if (_hasResult) ...[
              const Text("Campaign Analysis Result",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 10),

              // Sentiment + Score metrics
              Row(
                children: [
                  Expanded(child: _buildMetricMiniCard("SENTIMENT SCORE", "$_sentiment%", Colors.teal)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricMiniCard("RISK WEIGHT", _impactScore.toStringAsFixed(1), Colors.red.shade300)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMetricMiniCard("URGENCY", "$_urgency%", Colors.amber)),
                ],
              ),
              const SizedBox(height: 12),

              // ── ADVICE PANEL (structured, colour-coded) ──────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _healthColor.withOpacity(0.4), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _healthColor.withOpacity(0.12),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                      ),
                      child: Row(
                        children: [
                          Icon(_healthIcon, color: _healthColor, size: 18),
                          const SizedBox(width: 8),
                          Text("AI Profit Advice",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _healthColor)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _healthColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_campaignHealth,
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _healthColor)),
                          ),
                        ],
                      ),
                    ),
                    // Summary text (splits on '. ' to render steps)
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._splitAdviceLines(_summary).asMap().entries.map((entry) {
                            final i = entry.key;
                            final line = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 22, height: 22,
                                    decoration: BoxDecoration(
                                      color: _healthColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _healthColor.withOpacity(0.4)),
                                    ),
                                    child: Center(
                                      child: Text("${i + 1}",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _healthColor)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildFormattedAdviceLine(line),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ]
          ],
        ),
      ),
    );
  }

  /// Splits the backend summary string into individual action steps
  List<String> _splitAdviceLines(String summary) {
    // The backend advice uses '|' delimiters between steps and emoji flags
    // We split on common sentence terminators but keep emoji intact
    final raw = summary.replaceAll('. ', '.|').split('|');
    return raw.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  Widget _buildFormattedAdviceLine(String line) {
    // Regex to match [word:weight] format
    final regex = RegExp(r'\[([^:]+):([^\]]+)\]');
    final matches = regex.allMatches(line);
    if (matches.isEmpty) {
      return Text(line, style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0), height: 1.4));
    }

    final List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: line.substring(lastEnd, match.start)));
      }

      final word = match.group(1)!;
      final weightStr = match.group(2)!;
      final weight = double.tryParse(weightStr) ?? 0.0;

      Color badgeColor = Colors.yellow; // Fallback / 0 to 0.79
      if (weight >= 0.8) {
        badgeColor = Colors.greenAccent;
      } else if (weight < 0) {
        badgeColor = Colors.redAccent;
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withOpacity(0.8), width: 1),
            ),
            child: Text(
              '$word ($weightStr)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
            ),
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < line.length) {
      spans.add(TextSpan(text: line.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, color: Color(0xFFE2E8F0), height: 1.4),
        children: spans,
      ),
    );
  }

  Widget _buildProfitCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricMiniCard(String title, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: col)),
        ],
      ),
    );
  }
}

// (ElevatedButton helper extension removed)

// ==================== TAB 2: PRODUCT TAB ====================
class ProductTab extends StatefulWidget {
  final AIService aiService;
  final List<Map<String, dynamic>> reviews;
  final Function(Map<String, dynamic>) onReviewSimulated;

  const ProductTab({
    super.key,
    required this.aiService,
    required this.reviews,
  required this.onReviewSimulated,
  });

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> with SingleTickerProviderStateMixin {
  final TextEditingController _reviewTextController = TextEditingController();
  bool _isListening = false;
  int _activeNode = 0; // 0=none, 1=listener, 2=analyzer, 3=controller
  
  // Waveform animation helpers
  late AnimationController _waveController;
  final List<double> _waveHeights = [0.1, 0.4, 0.2, 0.7, 0.3, 0.8, 0.2, 0.5];

  // Results
  bool _hasResult = false;
  String _painpoint = "";
  String _category = "";
  double _impactScore = 0.0;
  String _recommendation = "";
  String _jsonPayload = "";

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _reviewTextController.dispose();
    super.dispose();
  }

  void _fetchRecentReviews() {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _activeNode = 1; // Listener Node Active
    });

    final prompts = [
      "The camera quality at night has terrible low light camera grain, adjust settings!",
      "I love the new UI, but loading custom analytics dashboard crashes the app",
      "We need HubSpot integrations because manual export is slow and bad"
    ];
    final selectedPrompt = prompts[Random().nextInt(prompts.length)];

    Timer(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        _reviewTextController.text = selectedPrompt;
        _isListening = false;
        _activeNode = 2; // Analyzer Active
      });

      _processFeedback();
    });
  }

  Future<void> _processFeedback() async {
    final text = _reviewTextController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _activeNode = 2;
    });

    final res = await widget.aiService.analyzeText(
      text: text,
      agentType: "product",
    );

    if (!mounted) return;
    setState(() {
      _activeNode = 3; // Controller active
      _hasResult = true;
      _painpoint = res.status == "Error" ? "Connection Error" : res.mainPoint;
      _category = res.category;
      _impactScore = res.impactScore;
      _recommendation = res.status == "Error" ? "Please ensure backend is running." : res.recommendation;
      _jsonPayload = res.jsonPayload;

      // Add to reviews list using actual backend sentiment
      if (res.status != "Error") {
        widget.onReviewSimulated({
          "id": "r" + (widget.reviews.length + 1).toString(),
          "platform": "Voice Feed (Live)",
          "rating": res.impactScore > 50 ? 2 : 5,
          "content": text,
          "sentiment": res.impactScore > 50 ? "Negative" : "Positive",
          "gap": _painpoint,
          "user": "Real User (Flutter)",
          "recommendation": res.recommendation
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Feedback Analyzed: \${res.impactScore > 50 ? 'Negative' : 'Positive'} Sentiment Detected")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Failed to connect to AI Backend. Please check IP address.")),
        );
      }
    });

    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _activeNode = 0; // Done
      });
    });
  }

  Future<void> _scanImageOCR() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _isListening = true;
          _reviewTextController.text = "Scanning image for text...";
        });
        
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final inputImage = InputImage.fromFilePath(pickedFile.path);
        final recognizedText = await textRecognizer.processImage(inputImage);
        
        setState(() {
          _reviewTextController.text = recognizedText.text;
          _isListening = false;
        });
        
        textRecognizer.close();
      }
    } catch (e) {
      setState(() {
        _isListening = false;
        _reviewTextController.text = "OCR Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Review Input Box
            const Text(
              "Enter Customer Review",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewTextController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Paste an Amazon customer review here to analyze returns, hijackers, and quality...",
                labelText: "Customer Review Text",
                border: OutlineInputBorder(),
                fillColor: Color(0xFF1E293B),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isListening ? null : _processFeedback,
                    child: const Text("ANALYZE COMPLAINTS", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.document_scanner, size: 18),
                  label: const Text("OCR", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _isListening ? null : _scanImageOCR,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Flow node visualizer
            const Text("Processing Steps", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNode("Listener", _activeNode == 1),
                  const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF64748B)),
                  _buildNode("Processor", _activeNode == 2),
                  const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF64748B)),
                  _buildNode("Controller", _activeNode == 3),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Outputs
            if (_hasResult) ...[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mock Amazon Review Card Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0F172A),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Icon(Icons.star_border, color: Colors.amber, size: 16),
                              Icon(Icons.star_border, color: Colors.amber, size: 16),
                              Icon(Icons.star_border, color: Colors.amber, size: 16),
                              SizedBox(width: 8),
                              Text("Verified Purchase", style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text("Reviewed on Amazon IN", style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildTag("[URGENT]", const Color(0xFFEF4444)),
                              const SizedBox(width: 8),
                              _buildTag("[${_category.toUpperCase()}]", const Color(0xFF38BDF8)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text("Main Issue: $_painpoint", style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Advice: $_recommendation", style: const TextStyle(fontSize: 12, color: Color(0xFFFBBF24))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildNode(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6366F1).withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? const Color(0xFF818CF8) : const Color(0xFF334155),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ==================== TAB 3: SALES TAB ====================
class SalesTab extends StatefulWidget {
  final AIService aiService;
  final List<Map<String, dynamic>> leads;
  final Function(Map<String, dynamic>) onLeadSimulated;
  final Function(String) onQualify;

  const SalesTab({
    super.key,
    required this.aiService,
    required this.leads,
    required this.onLeadSimulated,
    required this.onQualify,
  });

  @override
  State<SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  final _formKey = GlobalKey<FormState>();
  String _compName = "";
  String _contactRole = "";
  int _contractValue = 25000;
  String _signalDesc = "";

  // Results
  bool _hasResult = false;
  String _forecast = "Stable Growth";
  double _conversionRate = 0.5;
  String _suggestion = "";
  String _jsonPayload = "";

  Future<void> _submitSignal() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final res = await widget.aiService.analyzeText(
      text: _signalDesc,
      agentType: "sales",
    );

    setState(() {
      _hasResult = true;
      _conversionRate = double.parse((res.sentiment / 100.0).toStringAsFixed(2));
      _forecast = res.status == "Green" ? "High Growth" : (res.status == "Red" ? "Downside Risk" : "Stable Growth");
      _suggestion = res.recommendation;
      _jsonPayload = res.jsonPayload;

      // Add to leads list
      widget.onLeadSimulated({
        "id": "l" + (widget.leads.length + 1).toString(),
        "company": _compName,
        "signal": _signalDesc,
        "role": _contactRole,
        "value": _contractValue,
        "confidence": (res.sentiment).round(),
        "status": _conversionRate > 0.7 ? "Hot" : (_conversionRate < 0.4 ? "Cool" : "Warm")
      });
    });

    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Signal Scoring Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Check My Ad Profitability", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: "Product ASIN", border: OutlineInputBorder()),
                              validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                              onSaved: (val) => _compName = val!,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                              validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                              onSaved: (val) => _contactRole = val!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Daily Ad Spend (₹)", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        initialValue: "25000",
                        validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                        onSaved: (val) => _contractValue = int.tryParse(val!) ?? 25000,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: "Recent Ad Changes", border: OutlineInputBorder()),
                        validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                        onSaved: (val) => _signalDesc = val!,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06B6D4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        onPressed: _submitSignal,
                        child: const Text("CHECK AD PROFIT", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            if (_hasResult) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _conversionRate > 0.6 ? Colors.green.shade900 : Colors.red.shade900,
                      const Color(0xFF1E293B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _conversionRate > 0.6 ? Colors.green : Colors.red, width: 2),
                ),
                child: Column(
                  children: [
                    Text("PROFIT HEALTH: ${_forecast.toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text("PROFIT SCORE", style: TextStyle(fontSize: 10, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text("${(_conversionRate * 100).round()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                          ],
                        ),
                        Container(width: 1, height: 40, color: Colors.white24),
                        Column(
                          children: [
                            const Text("ADVICE", style: TextStyle(fontSize: 10, color: Colors.white70)),
                            const SizedBox(height: 4),
                            Icon(_conversionRate > 0.6 ? Icons.trending_up : Icons.warning_amber_rounded, color: Colors.white, size: 28),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_suggestion, style: const TextStyle(fontSize: 12.5, color: Colors.white, height: 1.4)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Active opportunities datatable
            const Text("Recent Ad Campaigns", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.leads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final l = widget.leads[idx];
                Color cardBorder = const Color(0xFF334155);
                Color accentColor = Colors.blue;
                if (l["status"] == "Hot") {
                  cardBorder = const Color(0xFF10B981);
                  accentColor = const Color(0xFF10B981);
                } else if (l["status"] == "Cool") {
                  cardBorder = const Color(0xFFEF4444);
                  accentColor = const Color(0xFFEF4444);
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory_2, color: accentColor, size: 18),
                              const SizedBox(width: 8),
                              Text("ASIN: ${l["company"]}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "₹${(l['value'] as int).toLocaleString()} Spend",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: accentColor),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text("Category: ${l['role']} | Profit Score: ${l['confidence']}%", style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 8),
                      Text("Notes: ${l["signal"]}", style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), fontStyle: FontStyle.italic)),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => widget.onQualify(l["id"]),
                            child: const Text("Keep Running", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444).withOpacity(0.15),
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => widget.onQualify(l["id"]),
                            child: const Text("Pause Ad", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBox(String title, String val, Color col) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: col)),
        ],
      ),
    );
  }
}

// ==================== TAB 4: STRATEGY TAB ====================
class StrategyTab extends StatefulWidget {
  final AIService aiService;
  final List<Map<String, dynamic>> recommendations;
  final List<Map<String, dynamic>> reviews;

  const StrategyTab({
    super.key,
    required this.aiService,
    required this.recommendations,
    required this.reviews,
  });

  @override
  State<StrategyTab> createState() => _StrategyTabState();
}

class _StrategyTabState extends State<StrategyTab> {
  bool _prodFailure = false;
  String _prodSignalText = "stable thermal logs";
  bool _mktFailure = false;
  String _mktSignalText = "stable campaign buzz";
  bool _salesFailure = false;
  String _salesSignalText = "stable pipeline";
  String? _selectedReviewProblem;

  // Results
  bool _hasResult = false;
  String _immediateAction = "Leverage high sentiment to scale core operations.";
  List<Map<String, dynamic>> _dynamicRecommendations = [];
  bool _isProcessing = false;

  Future<void> _runStrategySynthesis() async {
    setState(() {
      _isProcessing = true;
    });

    // Save previous telemetry so we don't permanently corrupt it with UI overrides
    final prevMkt = GlobalTelemetry.marketingSummary;
    final prevProd = GlobalTelemetry.productPainPoint;
    final prevSales = GlobalTelemetry.salesForecast;

    // Apply UI overrides if active, otherwise use the real telemetry cache
    GlobalTelemetry.marketingSummary = _mktFailure ? "PPC Fatigue" : prevMkt;
    GlobalTelemetry.productPainPoint = _prodFailure ? "Listing Hijack/Returns" : prevProd;
    GlobalTelemetry.salesForecast = _salesFailure ? "High ACoS/Low CVR" : prevSales;

    final res = await widget.aiService.analyzeText(
      text: "Synthesis Request",
      agentType: "strategy",
    );
    
    // Restore real telemetry after API call
    GlobalTelemetry.marketingSummary = prevMkt;
    GlobalTelemetry.productPainPoint = prevProd;
    GlobalTelemetry.salesForecast = prevSales;

    if (!mounted) return;
    
    List<Map<String, dynamic>> newRecs = [];
    String mainAction = res.status == "Error" ? "Backend connection failed." : res.mainPoint;
    
    if (res.status != "Error") {
        for (int i = 0; i < res.actionSteps.length; i++) {
          final step = res.actionSteps[i];
          final bool isRunway = step.startsWith('⏱️') || step.startsWith('💰') || step.startsWith('✅ FINANCIAL') || step.startsWith('📊 FINANCIAL');
          final bool isSeasonal = step.startsWith('📅');
          
          Color color = const Color(0xFF6366F1);
          IconData icon = Icons.check_circle;
          
          if (isRunway) {
            color = const Color(0xFF94A3B8);
            icon = Icons.account_balance_wallet;
          } else if (isSeasonal) {
            color = const Color(0xFF38BDF8);
            icon = Icons.calendar_month;
          } else if (mainAction.contains('🚨') || mainAction.contains('🔴') || mainAction.contains('💀')) {
            color = const Color(0xFFEF4444);
            icon = Icons.warning;
          } else if (mainAction.contains('⚠️')) {
            color = const Color(0xFFF59E0B);
            icon = Icons.error_outline;
          } else if (mainAction.contains('✅')) {
            color = const Color(0xFF10B981);
            icon = Icons.rocket_launch;
          }
          
          newRecs.add({
            "step": isRunway || isSeasonal ? "-" : (i + 1).toString(),
            "icon": icon,
            "color": color,
            "title": isRunway ? "Financial Runway" : (isSeasonal ? "Market Pulse" : "Playbook Step"),
            "desc": step,
          });
        }
    }

    setState(() {
      _hasResult = true;
      _immediateAction = mainAction;
      _dynamicRecommendations = newRecs;
      _isProcessing = false;
    });
  }

  void _resetMatrix() {
    setState(() {
      _prodFailure = false;
      _prodSignalText = "stable thermal logs";
      _mktFailure = false;
      _mktSignalText = "stable campaign buzz";
      _salesFailure = false;
      _salesSignalText = "stable pipeline";
      _hasResult = false;
    });
    // Do not automatically synthesize, let user click ask for advice
  }

  @override
  void initState() {
    super.initState();
    // Start with a clean slate
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Condition Matrix Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What is your biggest problem today?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    
                    // Product matrix trigger
                    _buildMatrixCell(
                      title: "My Sales are Dropping",
                      desc: _prodFailure ? "Sales volume has decreased" : "Sales are stable",
                      active: _prodFailure,
                      onTap: () {
                        setState(() {
                          _prodFailure = !_prodFailure;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Marketing matrix trigger
                    _buildMatrixCell(
                      title: "My Ad Costs (ACoS) are Too High",
                      desc: _mktFailure ? "ACoS is over 40%" : "ACoS is healthy",
                      active: _mktFailure,
                      onTap: () {
                        setState(() {
                          _mktFailure = !_mktFailure;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Sales matrix trigger
                    _buildMatrixCell(
                      title: "I am getting too many Returns",
                      desc: _salesFailure ? "Return rate > 10%" : "Return rate is normal",
                      active: _salesFailure,
                      onTap: () {
                        setState(() {
                          _salesFailure = !_salesFailure;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Negative Reviews from Feedback Page
                    ...widget.reviews.where((r) => r['sentiment'] == 'Negative').map((r) {
                      bool isActive = _selectedReviewProblem == r['id'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildMatrixCell(
                          title: "Negative Feedback: ${r['gap']}",
                          desc: (r['content'] as String).length > 50 ? (r['content'] as String).substring(0, 50) + "..." : r['content'],
                          active: isActive,
                          onTap: () {
                            setState(() {
                              _selectedReviewProblem = isActive ? null : r['id'];
                              if (!isActive) {
                                _hasResult = true;
                                _immediateAction = "Address Customer Feedback: ${r['gap']}";
                                _dynamicRecommendations = [
                                  {
                                    "step": "1",
                                    "icon": Icons.engineering,
                                    "color": Colors.orange,
                                    "title": "Technical / Senior Dev Advice",
                                    "desc": r['recommendation'] ?? "Check product logs for similar patterns to resolve the root cause.",
                                  },
                                  {
                                    "step": "2",
                                    "icon": Icons.support_agent,
                                    "color": Colors.blue,
                                    "title": "Customer Support",
                                    "desc": "Reach out to the customer and issue a replacement or refund to prevent further negative ratings and improve goodwill.",
                                  }
                                ];
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155), padding: const EdgeInsets.symmetric(horizontal: 14)),
                          onPressed: _resetMatrix,
                          child: const Text("Reset", style: TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(horizontal: 14)),
                          onPressed: _isProcessing ? null : _runStrategySynthesis,
                          child: const Text("Ask for Advice", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),



            // Action
            if (_hasResult) ...[
              Card(
                color: const Color(0xFF1E293B).withOpacity(0.6),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("What You Should Do Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444))),
                      const SizedBox(height: 6),
                      Text(_immediateAction, style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Strategic proposalsConfidence
            if (_hasResult) ...[
              const Text("Your Daily Action Plan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dynamicRecommendations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final r = _dynamicRecommendations[idx];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: r["color"].withOpacity(0.5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: r["color"].withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(r["icon"], color: r["color"], size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Step ${r['step']}: ${r['title']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(r["desc"], style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixCell({
    required String title,
    required String desc,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEF4444).withOpacity(0.15) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFFEF4444) : const Color(0xFF334155),
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              active ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: active ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

extension IntFormatter on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
