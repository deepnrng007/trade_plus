import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/providers.dart/StockProvider.dart';
import 'package:trade_plus/services.dart/price_ticker_socket_service.dart';
import 'package:trade_plus/services.dart/stocks_service.dart';

class RealTimeStockApp extends ConsumerStatefulWidget {
  const RealTimeStockApp({super.key});

  @override
  _RealTimeStockAppState createState() => _RealTimeStockAppState();
}

class _RealTimeStockAppState extends ConsumerState<RealTimeStockApp> {
  final WebSocketService wsSocket = WebSocketService();
  final StockApiService stockSymbolService =
      StockApiService("cscfm5hr01qpohrs3obgcscfm5hr01qpohrs3oc0");

  List<StockSymbol> symbols = [];
  int currentPage = 0;
  final int limit = 20; // Number of symbols per page
  bool isLoadingMore = false;
  bool hasMoreSymbols = true;

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
        wsSocket.subscribeToSymbols(newSymbols);
      });
    } else {
      setState(() {
        hasMoreSymbols = false; // No more symbols to load
      });
    }

    setState(() {
      isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Real-Time Stock Prices'),
        ),
        body: StreamBuilder(
          stream: wsSocket.priceStream,
          builder: (context, priceSnapshot) {
            final priceMap = priceSnapshot.data ?? {};

            // Use addPostFrameCallback to update the state
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
              itemCount: symbols.length + (hasMoreSymbols ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < symbols.length) {
                  final symbol = symbols[index];
                  final stockPrice = ref.watch(stockPriceProvider).firstWhere(
                        (s) => s.symbol == symbol.symbol,
                        orElse: () => StockPrice(symbol.symbol, 0.0),
                      );
                  return ListTile(
                    title: Text(symbol.description),
                    subtitle: Text('Price: ${stockPrice.price}'),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          },
        ));
  }
}
