# trade_plus


A Flutter application that displays real-time stock prices using WebSocket connections and implements efficient subscription management based on visible items in the viewport.

## Features

- Real-time stock price updates via WebSocket
- Infinite scrolling for loading more stock symbols
- Efficient WebSocket subscription management
- Optimized performance by subscribing only to visible symbols
- Clean and responsive UI

## Prerequisites

Before you begin, ensure you have met the following requirements:
- Flutter SDK (Version 3.0 or higher)
- Dart SDK (Version 2.17 or higher)
- A valid API key from your stock data provider
- Git for version control

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/real-time-stock-app.git

2. Navigate to the project directory:
cd trade_plus

3. Install dependencies:
flutter pub get

4. Create a .env file in the root directory and add your API key:
API_KEY=your_api_key_here


5. Run the app:
flutter run


-Performance Optimization
-The app implements several optimization techniques:

Lazy loading of stock symbols
Dynamic WebSocket subscription management
Viewport-based subscription control
Efficient memory management

