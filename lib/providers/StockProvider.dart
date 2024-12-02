import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trade_plus/models/StockPrice.dart';

class StockPriceNotifier extends StateNotifier<List<StockPrice>> {
  StockPriceNotifier() : super([]);

  void addStockPrice(StockPrice price) {
    state = [...state, price];
  }

  void updateStockPrice(String symbol, dynamic price) {
    final existingStockIndex = state.indexWhere((s) => s.symbol == symbol);

    if (existingStockIndex != -1) {
      state[existingStockIndex] = StockPrice(symbol, price);
    } else {
      state = [...state, StockPrice(symbol, price)];
    }
  }
}

// Provider for StockPriceNotifier
final stockPriceProvider = StateNotifierProvider<StockPriceNotifier, List<StockPrice>>((ref) {
  return StockPriceNotifier();
});