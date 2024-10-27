import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:trade_plus/models/Symbol.dart';
import '../real_time_stock_app_test.mocks.dart';

void main() {
  group('StockApiService', () {
    test('should fetch stock symbols', () async {
      final mockStockApiService = MockStockApiService();
      when(mockStockApiService.fetchSymbols()).thenAnswer((_) async => [
            StockSymbol(
                description: "AAPL", displaySymbol: "AAPL", symbol: "AAPL"),
            StockSymbol(
                description: "AAPL", displaySymbol: "AAPL", symbol: "AAPL"),
            StockSymbol(
                description: "AMZN", displaySymbol: "AMZN", symbol: "AMZN")
          ]);

      // Call the fetch method
      final symbols = await mockStockApiService.fetchSymbols();

      // Verify that fetchStockSymbols was called
      verify(mockStockApiService.fetchSymbols()).called(1);
      // Check the returned symbols
      final expectedList = [
        StockSymbol(description: "AAPL", displaySymbol: "AAPL", symbol: "AAPL"),
        StockSymbol(description: "AAPL", displaySymbol: "AAPL", symbol: "AAPL"),
        StockSymbol(description: "AMZN", displaySymbol: "AMZN", symbol: "AMZN")
      ];

      expect(
        symbols
            .map((e) => {'symbol': e.symbol, 'description': e.description})
            .toList(),
        expectedList
            .map((e) => {'symbol': e.symbol, 'description': e.description})
            .toList(),
      );
    });

    test('should throw an error in case no items found', () async {
      final mockStockApiService = MockStockApiService();

      // Simulate throwing an exception when no items are found
      when(mockStockApiService.fetchSymbols())
          .thenThrow(Exception('No items found'));

      // Verify that calling fetchStockSymbols throws an error
      expect(
        () async => await mockStockApiService.fetchSymbols(),
        throwsA(isA<Exception>().having(
            (e) => e.toString(), 'message', contains('No items found'))),
      );

      // Verify that fetchStockSymbols was called
      verify(mockStockApiService.fetchSymbols()).called(1);
    });
  });
}
