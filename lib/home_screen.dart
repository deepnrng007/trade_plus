// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trade_plus/services.dart/price_ticker_socket_service.dart';
// import 'package:trade_plus/services.dart/stocks_service.dart';
// import '../models//symbol.dart';

// class RealTimeStockApp extends ConsumerStatefulWidget {
//   const RealTimeStockApp({super.key});

//   @override
//   _RealTimeStockAppState createState() => _RealTimeStockAppState();
// }

// class _RealTimeStockAppState extends ConsumerState<RealTimeStockApp> {
//   final WebSocketService wsSocket = WebSocketService();
//   final StockApiService stockSymbolService =
//       StockApiService('cscfm5hr01qpohrs3obgcscfm5hr01qpohrs3oc0');
// // final symbols = [];

//   @override
//   void initState() {
//     super.initState();

//   }

//   @override
//   void dispose() {
//     wsSocket.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Real-Time Stock Prices'),
//       ),
//       body: FutureBuilder<List<String>>(
//           future: stockSymbolService.fetchSymbols(),
//           builder: (context, snapshot) {
//             if (snapshot.data != null) {
//               wsSocket.subscribeToSymbols(snapshot.data!);
//               final symbols = snapshot.data ?? [];
//               return ListView.builder(
//                 itemCount:
//                     symbols.length , // Extra item for loading indicator
//                 itemBuilder: (context, index) {
//                   String symbol = symbols[index];

//                   if (index == symbols.length) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   return ListTile(
//                     title: Text(symbol),
//                     subtitle: StreamBuilder(
//                         stream: wsSocket.priceStream,
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             print("object---- ${snapshot.data}");
//                             // final price = jsonDecode(snapshot.data)['data'][0]['p'];
//                             return Text(snapshot.data[symbol].toString());
//                           } else {
//                             return Text('Loading...');
//                           }
//                         }),
//                   );
//                 },
//               );
//             } else {
//               return const Center(child: CircularProgressIndicator());
//             }
//           }),
//     );
//   }

// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:trade_plus/services.dart/price_ticker_socket_service.dart';
// import 'package:trade_plus/services.dart/stocks_service.dart';

// class RealTimeStockApp extends ConsumerStatefulWidget {
//   const RealTimeStockApp({super.key});

//   @override
//   _RealTimeStockAppState createState() => _RealTimeStockAppState();
// }

// class _RealTimeStockAppState extends ConsumerState<RealTimeStockApp> {
//   final WebSocketService wsSocket = WebSocketService();
//   final StockApiService stockSymbolService =
//       StockApiService('cscfm5hr01qpohrs3obgcscfm5hr01qpohrs3oc0');

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     wsSocket.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Real-Time Stock Prices'),
//       ),
//       body: FutureBuilder<List<String>>(
//         future: stockSymbolService.fetchSymbols(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasData) {
//             final symbols = snapshot.data!;
//             wsSocket.subscribeToSymbols(symbols);

//             return StreamBuilder(
//               stream: wsSocket.priceStream,
//               builder: (context, priceSnapshot) {
//                 final priceMap = priceSnapshot.data ?? {};
//                 print("object---- ${priceSnapshot.data}");
//                 return ListView.builder(
//                   itemCount: symbols.length,
//                   itemBuilder: (context, index) {
//                     final symbol = symbols[index];
//                     final price = priceMap[symbol] ?? wsSocket.getPrice(symbol); // Get from stream or cache

//                     return ListTile(
//                       title: Text(symbol),
//                       subtitle: Text(
//                         price != null ? '\$${price.toStringAsFixed(2)}' : 'Loading...',
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           } else {
//             return const Center(child: Text('Failed to load symbols.'));
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trade_plus/services.dart/price_ticker_socket_service.dart';
import 'package:trade_plus/services.dart/stocks_service.dart';

class RealTimeStockApp extends ConsumerStatefulWidget {
  const RealTimeStockApp({super.key});

  @override
  _RealTimeStockAppState createState() => _RealTimeStockAppState();
}

// class _RealTimeStockAppState extends ConsumerState<RealTimeStockApp> {
//   final WebSocketService wsSocket = WebSocketService();
//   final StockApiService stockSymbolService =
//       StockApiService('cscfm5hr01qpohrs3obgcscfm5hr01qpohrs3oc0');

//   List<String> symbols = [];
//   int currentPage = 0;
//   final int limit = 20; // Number of symbols per page
//   bool isLoadingMore = false;
//   bool hasMoreSymbols = true;

//   late ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _scrollController.addListener(_scrollListener);
//     _loadMoreSymbols();
//   }

//   @override
//   void dispose() {
//     wsSocket.dispose();
//     _scrollController.removeListener(_scrollListener);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollListener() {
//     if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//       _loadMoreSymbols();
//     }
//   }

//   Future<void> _loadMoreSymbols() async {
//     if (isLoadingMore || !hasMoreSymbols) return;

//     setState(() {
//       isLoadingMore = true;
//     });

//     final newSymbols = await stockSymbolService.fetchSymbols(limit: limit,  offset: currentPage * limit);

//     if (newSymbols.isNotEmpty) {
//       setState(() {
//         currentPage++;
//         symbols.addAll(newSymbols);
//         wsSocket.subscribeToSymbols(newSymbols);
//       });
//     } else {
//       setState(() {
//         hasMoreSymbols = false;
//       });
//     }

//     setState(() {
//       isLoadingMore = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Real-Time Stock Prices'),
//       ),
//       body: StreamBuilder(
//         stream: wsSocket.priceStream,
//         builder: (context, priceSnapshot) {
//           final priceMap = priceSnapshot.data ?? {};
//           return ListView.builder(
//             controller: _scrollController,
//             itemCount: symbols.length + (isLoadingMore && hasMoreSymbols ? 1 : 0), // Extra item for loading indicator
//             itemBuilder: (context, index) {
//               if (index < symbols.length) {
//                 final symbol = symbols[index];
//                 final price = priceMap[symbol] ?? wsSocket.getPrice(symbol); // Get from stream or cache

//                 return ListTile(
//                   title: Text(symbol),
//                   subtitle: Text(
//                     price != null ? '\$${price.toStringAsFixed(2)}' : 'Loading...',
//                   ),
//                 );
//               } else {
//                 // Loading more indicator at the bottom
//                 return const Center(child: CircularProgressIndicator());
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class _RealTimeStockAppState extends ConsumerState<RealTimeStockApp> {
  final WebSocketService wsSocket = WebSocketService();
  final StockApiService stockSymbolService =
      StockApiService("cscfm5hr01qpohrs3obgcscfm5hr01qpohrs3oc0");

  List<String> symbols = [];
  int currentPage = 0;
  final int limit = 20; // Number of symbols per page
  bool isLoadingMore = false;
  bool hasMoreSymbols = true;

  late ScrollController _scrollController;
  final double itemHeight = 100.0; // Define a fixed item height

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
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Check if user has scrolled to the bottom
    if (currentScroll >= maxScroll) {
      _loadMoreSymbols();
    }

    // Determine which symbols are in view
    final visibleIndices = _getVisibleIndices();
    _manageSubscriptions(visibleIndices);
  }

  List<int> _getVisibleIndices() {
    final start = (_scrollController.position.pixels ~/ itemHeight)
        .clamp(0, symbols.length - 1);
    final end =
        ((start + (_scrollController.position.viewportDimension ~/ itemHeight))
            .clamp(0, symbols.length - 1));
    return List.generate(end - start + 1, (index) => start + index);
  }

  void _manageSubscriptions(List<int> visibleIndices) {
    // Subscribe to visible symbols
    for (var index in visibleIndices) {
      if (!wsSocket.isSubscribed(symbols[index])) {
        wsSocket.subscribeToSymbol(symbols[index]);
      }
    }

    // Unsubscribe from non-visible symbols
    // for (var i = 0; i < symbols.length; i++) {
    //   if (!visibleIndices.contains(i)) {
    //     wsSocket.unsubscribeFromSymbol(symbols[i]);
    //   }
    // }
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
        wsSocket.subscribeToSymbols(
            newSymbols); // Initial subscription to newly loaded symbols
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
          return ListView.builder(
            controller: _scrollController,
            itemCount: symbols.length,
            itemBuilder: (context, index) {
              final symbol = symbols[index];
              final price = priceMap[symbol] ?? 0.0;
              return ListTile(
                title: Text(symbol),
                subtitle: Text('Price : \$${price.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}
