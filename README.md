# MarketWatch: Autonomous Swarm Intelligence - COMPARATIVE WAR ROOM AI 

![MarketWatch](https://img.shields.io/badge/Status-Active-brightgreen) ![Flutter](https://img.shields.io/badge/Mobile-Flutter-blue) ![Dart Frog](https://img.shields.io/badge/Backend-Dart_Frog-0175C2)

**MarketWatch** is a next-generation, AI-powered "Swarm Intelligence" platform designed to act as an automated Chief Operating Officer (COO) and digital strategy team for e-commerce brands, SMBs, indie-hackers, and creators. 

In today’s hyper-competitive digital economy, analyzing market trends, tracking competitor ad spend, and understanding customer sentiment typically requires hiring an expensive team of data analysts and using fragmented SaaS tools. MarketWatch solves this by deploying a synchronized "swarm" of specialized AI agents. These agents autonomously monitor your business telemetry, extract actionable insights, and generate step-by-step strategies to maximize your profitability—all accessible via a unified Web Dashboard and a companion Flutter Mobile App.

---

## 🌟 Core Philosophy: Swarm Intelligence

Unlike traditional dashboards that passively display charts, MarketWatch uses **Swarm Intelligence**. This means our specialized AI agents do not operate in silos; they communicate with one another. 

For instance, if the **Product Agent** detects a sudden influx of negative reviews about a "stitching defect," it instantly alerts the **Strategy Agent**. The Strategy Agent then dynamically updates your "Action Plan" dashboard, providing immediate guidance on how to halt production, while simultaneously notifying the **Marketing Agent** to pause active ad campaigns for that specific SKU, preventing you from bleeding ad spend on a defective product.

---

## The Swarm Architecture (Core Agents)

MarketWatch is broken down into four distinct, communicating AI agents:

### 1. Marketing Agent (Ads Intelligence)
* **What it does:** Monitors your active ad campaigns and competitor advertisements across major platforms (Amazon, LinkedIn, Instagram, etc.).
* **Key Features:** 
  * **Automated Profitability Engine:** Automatically calculates vital metrics like Cost-Per-Click (CPC), Estimated Spend, and Return on Ad Spend (RoAS).
  * **Dynamic Risk Assessment:** Using custom weighted logic (e.g., assessing Spend vs. Clicks vs. Sentiment), it dynamically flags your ad-spend efficiency as *Critical*, *Normal*, or *Good*.
  * **Competitor Simulation:** Input a competitor's ASIN or Brand Name to instantly simulate and reverse-engineer their ad strategy.

### 2. Product Agent (Feedback Intelligence & OCR)
* **What it does:** Acts as your automated QA tester and product manager, synthesizing raw customer feedback into actionable engineering or manufacturing tasks.
* **Key Features:** 
  * **On-Device Optical Character Recognition (OCR):** Using Google ML Kit integrated directly into the Flutter companion app, users can use their smartphone camera to instantly scan physical return slips, warranty cards, or handwritten feedback.
  * **Defect Extraction via TF Lite:** Runs local TensorFlow Lite sentiment analysis to extract specific defects (e.g., "battery overheating", "UI crashes on login") from noisy customer complaints, categorizing them without needing a constant cloud connection.

### 3. Strategy Agent (Action Plan Generator)
* **What it does:** The central "brain" of the swarm that connects the dots between departments and generates your daily to-do list.
* **Key Features:** 
  * **Cross-Department Aggregation:** It aggregates critical warnings from the Marketing and Product agents.
  * **Targeted Remediation:** If a negative review is detected, it is flagged under *"What is your biggest problem today?"*. Clicking on this generates a targeted, step-by-step action plan. For example, a software bug yields "Senior Developer Advice" on patching the code, while a pricing issue yields "Business Strategy" on restructuring discount margins.

### 4. Sales Agent (Revenue Intelligence)
* **What it does:** Forecasts demand and manages supply-chain alerts based on live market telemetry.
* **Key Features:** 
  * **Demand Telemetry:** Ensures you never run out of stock during a trending spike or overstock during a market dip by analyzing historical sales velocity against current marketing sentiment.

---

## 💻 Technology Stack & Architecture

MarketWatch is built using a highly optimized, purely Dart-based ecosystem, ensuring seamless code-sharing between the frontend and the backend.

* **Mobile Application (Frontend):** 
  * Built with **Flutter & Dart**.
  * Features an immersive, dynamic telemetry UI.
  * Utilizes on-device ML for Camera access and OCR scanning.
* **Web Command Center (Frontend):** 
  * Built with **Vanilla HTML/CSS/JS**.
  * Features a lightweight, modern "glassmorphism" aesthetic for deep-dive desktop monitoring.
* **Backend Engine & Routing:** 
  * Built with **Dart Frog**.
  * Handles REST API routing, state management, and agent orchestration in a completely stateless environment.
* **Machine Learning & AI:** 
  * **TensorFlow Lite (Edge classification):** Used for fast, on-device sentiment scoring.
  * **Google ML Kit:** Powers the Text Recognition and OCR pipelines.
  * **Generative AI Prompting:** Advanced prompt engineering handles complex strategy generation and cross-agent communication.

---

## The Problem it Solves

Indian SMBs, D2C brands, indie-hackers, and student developers operate in highly competitive markets with razor-thin margins. The barrier to entry for enterprise-grade market intelligence is prohibitively high. 

**MarketWatch democratizes this data.** It allows a one-person team to instantly know:
1. Why their ads are failing.
2. Why their app/product is getting negative reviews.
3. Exactly what steps they need to take to fix it.

It replaces the need for an expensive marketing agency, a dedicated QA tester, and a business consultant, rolling them all into one lightweight application.

---

## 🛠 Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for compiling the mobile app)
- [Dart](https://dart.dev/get-dart) (for running the Dart Frog backend)

### 1. Running the Backend (Dart Frog)
The backend orchestrates the AI agents and handles API requests.
```bash
# Navigate to the backend directory
cd backend

# Fetch dependencies
dart pub get

# Start the development server
dart_frog dev
```
*The backend will typically run on `http://localhost:8080`.*

### 2. Running the Web Dashboard
The web dashboard is a static frontend that interacts with the Dart Frog backend.
```bash
# Navigate to the frontend directory
cd frontend

# Serve the static files (using Python's built-in server as an example)
python -m http.server 8081
```
*Open `http://localhost:8081/index.html` in your browser.*

### 3. Running the Flutter Mobile App
The mobile app provides on-the-go telemetry and on-device OCR scanning.
```bash
# Navigate to the mobile app directory
cd marketwatch_app

# Fetch Flutter dependencies
flutter pub get

# Run on your connected Android/iOS device or emulator
flutter run
```

---

## 🚀 Future Roadmap
- **Automated Ad Bidding:** Allowing the Marketing Agent to automatically adjust Facebook/Google ad bids via API based on RoAS scores.
- **Shopify/WooCommerce Integration:** Directly pulling sales velocity and inventory data from popular e-commerce platforms.
- **Voice-Activated Strategy Briefings:** Allowing the Strategy Agent to give a daily 60-second audio brief on market conditions using Text-to-Speech (TTS).

---
*Built with ❤️ for the next generation of builders and creators.*
