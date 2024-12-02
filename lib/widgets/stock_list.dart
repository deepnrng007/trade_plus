import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trade_plus/models/StockPrice.dart';
import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/providers/StockProvider.dart';
import 'package:trade_plus/services/price_ticker_socket_service.dart';
import 'package:trade_plus/services/stocks_service.dart';
import 'package:trade_plus/utils/constants.dart';
import 'package:trade_plus/widgets/search_input.dart';

class StockList extends ConsumerStatefulWidget {
  const StockList({super.key});

  @override
  _RealTimeStockAppState createState() => _RealTimeStockAppState();
}

class _RealTimeStockAppState extends ConsumerState<StockList> {
  final WebSocketService wsSocket = WebSocketService();

  final StockApiService stockSymbolService = StockApiService(Constants.apiKey);

  List<StockSymbol> symbols = [];
  int currentPage = 0;
  final int limit = 20; // Number of symbols per page
  bool isLoadingMore = false;
  bool hasMoreSymbols = true;
  List<StockSymbol> filteredSymbols = []; // List for filtered symbols

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _loadMoreSymbols();
  }

  @override
  void dispose() {
    wsSocket.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreSymbols();
    } else {
      _updateSubscriptions();
    }
  }

  Future<void> _loadMoreSymbols() async {
    if (isLoadingMore || !hasMoreSymbols) return;

    setState(() {
      isLoadingMore = true;
    });

    final newSymbols = await stockSymbolService.fetchSymbols(
        limit: limit, offset: currentPage * limit);

    if (newSymbols.isNotEmpty) {
      setState(() {
        currentPage++;
        symbols.addAll(newSymbols);
        filteredSymbols = List.from(symbols);
      });
      _updateSubscriptions(); // Update subscriptions after loading new symbols
    } else {
      setState(() {
        hasMoreSymbols = false; // No more symbols to load
      });
    }

    setState(() {
      isLoadingMore = false;
    });
  }

  void _updateSubscriptions() {
    int startIndex = (_scrollController.position.pixels ~/ 70) - 10;
    int endIndex = startIndex + 30;

    startIndex = startIndex.clamp(0, symbols.length - 1);
    endIndex = endIndex.clamp(0, symbols.length);

    for (var symbol in symbols) {
      wsSocket.unsubscribeFromSymbol(symbol.symbol);
    }

    for (var i = startIndex; i < endIndex; i++) {
      if (i < symbols.length) {
        wsSocket.subscribeToSymbol(symbols[i].symbol);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(Constants.appTitle),
        ),
        body: Column(
          children: [
            SearchInputWidget(
              onTextChanged: (searchQuery) {
                setState(() {
                  filteredSymbols = symbols
                      .where((symbol) => symbol.description
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList();
                });
              },
            ),
            Expanded(
              child: StreamBuilder(
                stream: wsSocket.priceStream,
                builder: (context, priceSnapshot) {
                  final priceMap = priceSnapshot.data ?? {};

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    for (var symbol in symbols) {
                      if (priceMap.containsKey(symbol.symbol)) {
                        final price = priceMap[symbol.symbol];
                        if (price != null) {
                          ref
                              .read(stockPriceProvider.notifier)
                              .updateStockPrice(symbol.symbol, price);
                        }
                      }
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        filteredSymbols.length + (hasMoreSymbols ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < filteredSymbols.length) {
                        final symbol = filteredSymbols[index];
                        final stockPrice =
                            ref.watch(stockPriceProvider).firstWhere(
                                  (s) => s.symbol == symbol.symbol,
                                  orElse: () => StockPrice(symbol.symbol, 0.0),
                                );
                        return ListTile(
                          title: Text(symbol.description),
                          subtitle: Text('Price: ${stockPrice.price}'),
                          titleTextStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                          subtitleTextStyle: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }
}
