# MarketWatch: Autonomous Swarm Intelligence 

![MarketWatch](https://img.shields.io/badge/Status-Active-brightgreen) ![Flutter](https://img.shields.io/badge/Mobile-Flutter-blue) ![Dart Frog](https://img.shields.io/badge/Backend-Dart_Frog-0175C2)

**MarketWatch** is an AI-powered "Swarm Intelligence" platform that acts as an automated Chief Operating Officer (COO) and digital strategy team for e-commerce brands, SMBs, and indie-creators.

Built with a unified **Web Dashboard** and a companion **Flutter mobile app**, MarketWatch eliminates the need for expensive data analysts by deploying a swarm of specialized AI agents that monitor marketing spend, synthesize customer feedback, and generate actionable business strategies in real-time.

---

## The Swarm Architecture (Core Agents)

MarketWatch is broken down into four distinct, communicating AI agents:

### 1. Marketing Agent (Ads Intelligence)
* **What it does:** Monitors competitor ad campaigns across platforms like Amazon, LinkedIn, and Instagram. 
* **Key Features:** Automatically calculates Cost-Per-Click (CPC) and Return on Ad Spend (RoAS). Using custom weighted logic, it dynamically flags your ad-spend efficiency as *Critical*, *Normal*, or *Good*, preventing you from bleeding money on inefficient campaigns.

### 2. Product Agent (Feedback Intelligence)
* **What it does:** Acts as your automated QA and product manager.
* **Key Features:** Features on-device Camera/OCR (via Google ML Kit) to scan physical return slips or digital reviews. It runs local TF Lite sentiment analysis to extract specific product defects (e.g., "battery overheating" or "stitching issues") and categorizes them instantly.

### 3. Strategy Agent (Action Plan)
* **What it does:** The "brain" of the swarm that connects the dots between departments.
* **Key Features:** It automatically aggregates critical warnings from the Marketing and Product agents. For example, if a negative review is detected by the Product Agent, the Strategy Agent instantly flags it under *"What is your biggest problem today?"* and generates targeted, step-by-step "Senior Developer Advice" or "Business Strategy" to fix the issue.

### 4. Sales Agent (Revenue Intelligence)
* **What it does:** Forecasts demand and manages supply-chain alerts based on live market telemetry to ensure you never run out of stock during a trending spike.

---

## Technology Stack

* **Mobile Application:** Flutter & Dart (featuring on-device ML, Camera access, and dynamic telemetry UI).
* **Web Command Center:** Vanilla HTML/CSS/JS (Lightweight, glassmorphism UI for desktop monitoring).
* **Backend Routing:** Dart Frog (REST APIs, agent orchestration).
* **Machine Learning:** TensorFlow Lite (Edge classification), Google ML Kit (Text Recognition/OCR), and advanced generative AI prompting for strategy generation.

---

## The Problem it Solves

Indian SMBs, D2C brands, and student developers operate in highly competitive markets with razor-thin margins. They cannot afford dedicated marketing agencies or product managers. MarketWatch democratizes enterprise-grade data analytics, allowing a one-person team to instantly know why their ads are failing or why their app is getting negative reviews, accompanied by an immediate AI-generated action plan to fix it.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (for mobile app)
- [Dart](https://dart.dev/get-dart) (for Dart Frog backend)

### Running the Backend
1. Navigate to the `backend` directory.
2. Run `dart pub get`
3. Run the Dart Frog server: `dart_frog dev`

### Running the Web Dashboard
1. Navigate to the `frontend` directory.
2. Serve the static files (e.g., using python simple server): `python -m http.server 8080`
3. Open `http://localhost:8080/index.html`

### Running the Flutter Mobile App
1. Navigate to the `marketwatch_app` directory.
2. Run `flutter pub get`
3. Run `flutter run` on your connected device or emulator.
