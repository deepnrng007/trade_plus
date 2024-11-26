// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:trade_plus/bloc/stock_list/stock_list_bloc.dart';
// import 'package:trade_plus/bloc/stock_list/stock_list_event.dart';
// import 'package:trade_plus/bloc/stock_price/stock_price_bloc.dart';
// import 'package:trade_plus/bloc/stock_price/stock_price_event.dart';
// import 'package:trade_plus/models/Symbol.dart';
// import 'package:trade_plus/services/price_ticker_socket_service.dart';
// import 'package:trade_plus/services/stocks_service.dart';
// import 'package:trade_plus/utils/constants.dart';
// import 'package:trade_plus/widgets/screens/stock_detail_screen.dart';
// import 'package:trade_plus/widgets/search_input.dart';

// class StockList extends StatelessWidget {
//   const StockList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final stockSymbolService = StockApiService(Constants.apiKey);
//     final wsSocket = WebSocketService();

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => StockListBloc(stockSymbolService).add(LoadMoreSymbols()),
//         ),
//         BlocProvider(
//           create: (context) => StockPriceBloc()..add(UpdateStockPrice("", 0.0)), // Initial event
//         ),
//       ],
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(Constants.appTitle),
//         ),
//         body: Column(
//           children: [
//             SearchInputWidget(
//               onTextChanged: (searchQuery) {
//                 context.read<StockListBloc>().add(FilterSymbols(searchQuery));
//               },
//             ),
//             Expanded(
//               child: BlocBuilder<StockListBloc, StockListState>(
//                 builder: (context, state) {
//                   if (state.isLoadingMore && state.symbols.isEmpty) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   return ListView.builder(
//                     itemCount: state.filteredSymbols .length + (state.hasMoreSymbols ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (index < state.filteredSymbols.length) {
//                         final symbol = state.filteredSymbols[index];
//                         return BlocBuilder<StockPriceBloc, StockPriceState>(
//                           builder: (context, priceState) {
//                             final stockPrice = priceState.prices.firstWhere(
//                               (p) => p.symbol == symbol.symbol,
//                               orElse: () => StockPrice(symbol.symbol, 0.0),
//                             );
//                             return ListTile(
//                               title: Text(symbol.description),
//                               subtitle: Text('Price: ${stockPrice.price}'),
//                               titleTextStyle: const TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20.0),
//                               subtitleTextStyle: const TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16.0),
//                               onTap: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StockDetailScreen(symbol: symbol.symbol),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       } else {
//                         context.read<StockListBloc>().add(LoadMoreSymbols());
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }