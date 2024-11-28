import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/repository/stock_repository.dart';
import 'package:trade_plus/services/api_response.dart';

class StockListNotifier extends StateNotifier<StockListState> {
  final StockRepository _stockRepository;

  StockListNotifier(this._stockRepository) : super(StockListState.initial());

  Future<void> fetchStockList() async {
    state = StockListState(stockList: ApiResponse.loading());

    try {
      final stocks = await _stockRepository.fetchStocks();
      final stockList = stocks.skip(0).take(20).toList();
      state = StockListState(stockList: ApiResponse.complete(stockList));
    } catch (error) {
      state = StockListState(stockList: ApiResponse.error(error.toString()));
    }
  }

  Future<void> fetchMoreStocks(
      {required int limit, required int offset}) async {
    // state = StockListState(stockList: ApiResponse.loading());
    try {
      final stocks = await _stockRepository.fetchStocks();
      final stockList = stocks.skip(offset).take(limit).toList();
      state = StockListState(stockList: ApiResponse.complete(stockList));
    } catch (error) {
      state = StockListState(stockList: ApiResponse.error(error.toString()));
    }
  }
}

class StockListState {
  final ApiResponse<List<StockSymbol>> stockList;

  StockListState({required this.stockList});

  factory StockListState.initial() {
    return StockListState(stockList: ApiResponse.loading());
  }
}

final stockListProvider =
    StateNotifierProvider<StockListNotifier, StockListState>((ref) {
  final stockRepository = StockRepository(); // Create or inject the repository
  return StockListNotifier(stockRepository);
});
