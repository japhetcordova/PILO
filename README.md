# Fuel — AI Meal Decision Engine

[Flutter](https://flutter.dev/) | [Android](https://developer.android.com/) | [License: MIT](https://opensource.org/licenses/MIT)

Eliminate food decision fatigue with one perfect meal recommendation, powered by on-device AI.

Fuel is an offline-first Android app that scans your pantry, tracks inventory, and generates a single, tailored meal suggestion using local AI—no internet required. Say goodbye to endless scrolling and hello to fast, confident cooking.

## Overview

Fuel transforms the chaos of meal planning into a streamlined experience. By leveraging on-device machine learning, it analyzes your available ingredients, time constraints, and preferences to deliver exactly one meal recommendation. Designed for busy individuals who want quick decisions without the overwhelm of choice.

Why Fuel?  
In a world of endless recipe apps, Fuel focuses on simplicity: one decision, one meal, one tap to cook. It's fully offline, privacy-focused, and optimized for speed.

## Problem & Solution

The Problem:  
Meal planning is exhausting. Scrolling through hundreds of recipes, checking ingredients, and factoring in time leads to decision fatigue. Traditional apps rely on cloud services, compromising privacy and requiring constant connectivity.

The Solution:  
Fuel uses on-device AI to scan your pantry in seconds, track expiration dates, and generate a personalized recipe instantly. No data leaves your device, ensuring privacy and reliability—even offline.

## Features

- Fast Manual Entry: Quickly type and add your ingredients, maintaining a lightweight and speedy experience.
- Progressive Offline Learning: Train the AI on local and regional ingredients (e.g., Bisaya, Filipino items). The AI learns from your descriptions for better offline context.
- Online Enrichment Sync: Automatically re-evaluates and enriches your user-trained ingredients in the background whenever an internet connection is detected.
- Offline AI Recipes: Local large language model generates one tailored meal suggestion based on your constraints and custom trained knowledge.
- Multiple Pantries: Separate your inventory into Breakfast, Lunch, and Dinner groups.
- Daily Meal Tracker: A built-in calendar to log and visualize your eating habits.
- Single-Decision UX: No endless lists—just one clear recommendation to reduce choice paralysis.
- Fast Cooking Mode: Step-by-step guidance with timers for efficient, distraction-free cooking.
- Privacy-First: Core operation is offline; no data sent to external servers unless syncing.

## Tech Stack

- Framework: Flutter (Dart)
- Platform: Android (Kotlin for native integration)
- AI/ML: On-device vision (Google ML Kit), Local LLM for recipe generation
- Storage: Local SQLite for inventory
- Build Tools: Gradle (Android), Flutter SDK

## Architecture

Fuel follows an offline-first architecture with modular layers:

- Presentation Layer: Flutter widgets for UI (inventory screen, manual input, offline training, cooking mode).
- Domain Layer: Business logic for meal decisions, pantry management, and progressive learning.
- Data Layer: Local repositories for inventory, custom trained ingredients, and AI services.
- Sync Layer: Background service via `connectivity_plus` to enrich local offline context when online.
- AI Integration: On-device model for text generation, ensuring zero latency and privacy.

All core processing happens locally on the device, with supplementary online syncs.

## Installation & Setup

### Prerequisites
- Flutter SDK (3.0+): [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 26+)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/fuel.git
   cd fuel
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Android:
   - Open in Android Studio or VS Code.
   - Ensure local.properties points to your Android SDK.

4. Run the app:
   ```bash
   flutter run
   ```

For detailed setup, see [Flutter documentation](https://flutter.dev/docs/get-started).

## Usage Guide

1. Add Ingredients: Tap "Add Ingredients", quickly type what you have—Fuel identifies and adds them to your inventory.
2. Teach Pilo: Tap "Teach Pilo" if you have a local ingredient (like Batuan) the offline AI might not know well. Fill in its flavor profile to help Pilo learn!
3. Get Recommendation: Tap "Ask Pilo for a Meal"—receive one tailored recipe instantly.
4. Cook Mode: Follow step-by-step instructions with built-in timers.
5. Online Sync: Connect to Wi-Fi to let Pilo automatically double-check and enrich the custom ingredients you've taught it.

Fuel is intuitive: input, teach, decide, cook—all in under a minute.

## Screenshots

(Screenshots coming soon—placeholder for app interface)

- Fast Manual Input Interface
- Offline Ingredient Training Screen
- Meal Recommendation Screen
- Cooking Mode with Steps

## Monetization

Fuel is currently free and open-source. Future plans may include premium features like advanced AI customizations or cloud sync (opt-in).

## Roadmap

- Enhanced AI models for better recipe personalization
- iOS support via Flutter
- Integration with smart kitchen devices
- Community recipe sharing (offline-first)

## Contributing

We welcome contributions! Fuel is an open-source project under the MIT License.

1. Fork the repo and create a feature branch.
2. Follow Flutter best practices and add tests.
3. Submit a pull request with a clear description.

For issues or ideas, open a GitHub issue. See CONTRIBUTING.md for details.

## License

This project is licensed under the MIT License—see LICENSE for details.

Built with love for efficient, mindful eating.  
[Download on Google Play](https://play.google.com/store/apps/details?id=com.example.fuel) (Coming Soon) | [GitHub](https://github.com/yourusername/fuel) | [Documentation](https://github.com/yourusername/fuel/wiki)
