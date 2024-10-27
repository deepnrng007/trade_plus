

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/real_time_stock_app.dart';
import 'package:trade_plus/services.dart/price_ticker_socket_service.dart';
import 'package:trade_plus/services.dart/stocks_service.dart';

import 'real_time_stock_app_test.mocks.dart';

void main() {
  late MockWebSocketService mockWebSocketService;
  late MockStockApiService mockStockApiService;

  setUp(() {
    mockWebSocketService = MockWebSocketService();
    mockStockApiService = MockStockApiService();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          webSocketServiceProvider.overrideWithValue(mockWebSocketService),
          stockApiServiceProvider.overrideWithValue(mockStockApiService),
        ],
        child: const MaterialApp(
          home: RealTimeStockApp(),
        ),
      ),
    );
  }

  testWidgets('Displays loading indicator initially', (tester) async {
    when(mockStockApiService.fetchSymbols(limit: anyNamed('limit'), offset: anyNamed('offset')))
        .thenAnswer((_) async => []);

    await pumpApp(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Displays symbols and their prices', (tester) async {
    final mockSymbols = [
      StockSymbol(symbol: 'AAPL', description: 'Apple Inc.', displaySymbol: "mock"),
      StockSymbol(symbol: 'GOOGL', description: 'Alphabet Inc.', displaySymbol: "mock"),
    ];

    when(mockStockApiService.fetchSymbols(limit: anyNamed('limit'), offset: anyNamed('offset')))
        .thenAnswer((_) async => mockSymbols);

    when(mockWebSocketService.priceStream).thenAnswer((_) =>
        Stream.value({'AAPL': 150.0, 'GOOGL': 2800.0})); // Mock the WebSocket stream

    await pumpApp(tester);

    // Trigger the loading of symbols
    await tester.pumpAndSettle();

    // Verify that symbols and their prices are displayed
    expect(find.text('Apple Inc.'), findsOneWidget);
    expect(find.text('Price: 150.0'), findsOneWidget);

    expect(find.text('Alphabet Inc.'), findsOneWidget);
    expect(find.text('Price: 2800.0'), findsOneWidget);
  });

  testWidgets('Pagination loading more symbols', (tester) async {
    final mockSymbolsPage1 = List.generate(
      20,
      (index) => StockSymbol(symbol: 'SYM$index', description: 'Description $index', displaySymbol: "mock"),
    );
    final mockSymbolsPage2 = List.generate(
      20,
      (index) => StockSymbol(symbol: 'SYM${index + 20}', description: 'Description ${index + 20}', displaySymbol: "mock"),
    );

    when(mockStockApiService.fetchSymbols(limit: anyNamed('limit'), offset: 0))
    .thenAnswer((_) async => Future.value(mockSymbolsPage1 as FutureOr<List<StockSymbol>>?)); // Ensure it's a Future

when(mockStockApiService.fetchSymbols(limit: anyNamed('limit'), offset: 20))
    .thenAnswer((_) async => Future.value(mockSymbolsPage2 as FutureOr<List<StockSymbol>>?)); // Ensure it's a Future

    await pumpApp(tester);

    // Load the first page of symbols
    await tester.pumpAndSettle();

    // Scroll to the bottom to trigger pagination
    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();

    // Verify that the second page of symbols is displayed
    expect(find.text('Description 0'), findsOneWidget);
    expect(find.text('Description 19'), findsOneWidget);
    expect(find.text('Description 20'), findsOneWidget);
    expect(find.text('Description 39'), findsOneWidget);
  });

  testWidgets('Updates prices from WebSocket stream', (tester) async {
    final mockSymbols = [
      StockSymbol(symbol: 'AAPL', description: 'Apple Inc.', displaySymbol: "mock"),
      StockSymbol(symbol: 'GOOGL', description: 'Alphabet Inc.',  displaySymbol: "mock"),
    ];

    when(mockStockApiService.fetchSymbols(limit: anyNamed('limit'), offset: anyNamed('offset')))
        .thenAnswer((_) async => mockSymbols);

    final priceStreamController = StreamController<Map<String, double>>();

    when(mockWebSocketService.priceStream).thenAnswer((_) => priceStreamController.stream);

    await pumpApp(tester);

    // Load symbols
    await tester.pumpAndSettle();

    // Verify initial prices are loading
    expect(find.text('Loading...'), findsNWidgets(2));

    // Send price updates through the WebSocket
    priceStreamController.add({'AAPL': 155.0, 'GOOGL': 2850.0});
    await tester.pumpAndSettle();

    // Verify the updated prices
    expect(find.text('Price: 155.0'), findsOneWidget);
    expect(find.text('Price: 2850.0'), findsOneWidget);

    priceStreamController.close();
  });
}
