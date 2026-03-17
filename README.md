# Pilo — AI Meal Decision Engine

[Flutter](https://flutter.dev/) | [Android](https://developer.android.com/) | [License: MIT](https://opensource.org/licenses/MIT)

Eliminate food decision fatigue with one perfect meal recommendation, powered by on-device AI.

Pilo is an offline-first Android app that manages your pantry, tracks nutrition, and generates tailored meal suggestions using local AI—no internet required. Say goodbye to endless scrolling and hello to fast, confident cooking.

## Overview

Pilo transforms the chaos of meal planning into a streamlined experience. By leveraging on-device machine learning, it analyzes your available ingredients, time constraints, and preferences to deliver exactly one meal recommendation. Designed for busy individuals who want quick decisions without the overwhelm of choice.

Why Pilo?  
In a world of endless recipe apps, Pilo focuses on simplicity: one decision, one meal, one tap to cook. It's fully offline, privacy-focused, and optimized for speed.

## Problem & Solution

The Problem:  
Meal planning is exhausting. Scrolling through hundreds of recipes, checking ingredients, and factoring in time leads to decision fatigue. Traditional apps rely on cloud services, compromising privacy and requiring constant connectivity.

The Solution:  
Pilo uses on-device AI to manage your pantry, track expiration dates, and generate personalized recipes instantly. No data leaves your device, ensuring privacy and reliability—even offline.

## Features

- **One-Tap Recipe Generation**: Get exactly one tailored meal suggestion based on your current inventory.
- **Nutrition Dashboard**: Track your daily caloric and nutrient intake to maintain a healthy lifestyle.
- **Water Consumption Streak**: Stay hydrated with a gamified tracker that encourages daily water intake goals.
- **Fast Manual Entry**: Quickly add ingredients to your pantry with an intuitive interface.
- **Offline Ingredient Training**: Teach Pilo about local or specialized ingredients to improve its contextual knowledge.
- **Progressive Sync**: Optional background sync to enrich local AI knowledge when an internet connection is available.
- **Multiple Pantries**: Organize your inventory by meal type (Breakfast, Lunch, Dinner).
- **Daily Meal Tracker**: A built-in calendar to log your meals and visualize eating habits.
- **Premium Features**: Unlock advanced AI customizations and enhanced tracking capabilities.
- **Privacy-First**: Core operations run entirely on-device; your data stays yours.

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **AI/ML**: MediaPipe GenAI (On-device Large Language Model)
- **Local Database**: Hive
- **Persistence**: Path Provider
- **Networking**: Dio (for optional sync)

## Installation & Setup

### Prerequisites
- Flutter SDK (3.20+): [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 26+)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/japhetcordova/pilo.git
   cd pilo
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate data models (if needed):
   ```bash
   flutter pub run build_runner build
   ```

4. Build for Release:
   ```bash
   flutter build apk --release
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Usage Guide

1. **Add Ingredients**: Use the Manual Input feature to quickly list what's in your pantry.
2. **Track Nutrition**: Log your meals to see your daily progress in the Nutrition Dashboard.
3. **Stay Hydrated**: Update your water intake throughout the day to keep your streak alive.
4. **Ask Pilo**: Tap the recommendation button to get your meal for the day.
5. **Teach Pilo**: Help the AI learn about unique ingredients by providing flavor profiles and descriptions.

## Roadmap

- Enhanced AI models for even faster recipe generation.
- iOS support via Flutter.
- Advanced community features (offline-first).
- Smart kitchen integration.

## Contributing

We welcome contributions! Pilo is an open-source project under the MIT License.

1. Fork the repo and create a feature branch.
2. Follow Flutter best practices and add tests.
3. Submit a pull request with a clear description.

## License

This project is licensed under the MIT License—see [LICENSE](LICENSE) for details.

Built with love for efficient, mindful eating.  
[GitHub](https://github.com/japhetcordova/pilo) | [Issues](https://github.com/japhetcordova/pilo/issues)
