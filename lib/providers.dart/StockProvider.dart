import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a model for StockPrice
class StockPrice {
  final String symbol;
  final dynamic price;

  StockPrice(this.symbol, this.price);
}

// StateNotifier to manage stock prices
class StockPriceNotifier extends StateNotifier<List<StockPrice>> {
  StockPriceNotifier() : super([]);

  void addStockPrice(StockPrice price) {
    state = [...state, price];
  }

  void updateStockPrice(String symbol, dynamic price) {
    // Check if the symbol already exists
    final existingStockIndex = state.indexWhere((s) => s.symbol == symbol);

    if (existingStockIndex != -1) {
      // Update the price if the stock already exists
      state[existingStockIndex] = StockPrice(symbol, price);
    } else {
      // If the stock does not exist, add it to the state
      state = [...state, StockPrice(symbol, price)];
    }
  }
}

// Provider for StockPriceNotifier
final stockPriceProvider = StateNotifierProvider<StockPriceNotifier, List<StockPrice>>((ref) {
  return StockPriceNotifier();
});