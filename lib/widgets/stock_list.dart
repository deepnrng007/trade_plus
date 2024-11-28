import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trade_plus/bloc/stock_list/stock_list_bloc.dart';
import 'package:trade_plus/bloc/stock_list/stock_list_event.dart';
import 'package:trade_plus/bloc/stock_list/stock_list_state.dart';
import 'package:trade_plus/bloc/stock_price/stock_price_bloc.dart';
import 'package:trade_plus/bloc/stock_price/stock_price_event.dart';
import 'package:trade_plus/bloc/stock_price/stock_price_state.dart';
import 'package:trade_plus/models/StockPrice.dart';
import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/utils/constants.dart';
import 'package:trade_plus/utils/enums.dart';
import 'package:trade_plus/widgets/screens/stock_detail_screen.dart';
import 'package:trade_plus/widgets/search_input.dart';

class StockList extends ConsumerStatefulWidget {
  const StockList({super.key});

  @override
  _RealTimeStockAppState createState() => _RealTimeStockAppState();
}

class _RealTimeStockAppState extends ConsumerState<StockList> {
  final limit = 20;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    context.read<StockListBloc>().add(FetchSymbols());
  }

  @override
  void dispose() {
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
    final cPage = context.read<StockListBloc>().state.currentPage;
    context
        .read<StockListBloc>()
        .add(LoadMoreSymbols(limit: limit, offset: cPage * limit));
  }

  void _updateSubscriptions() {
    int startIndex = (_scrollController.position.pixels ~/ 70) - 10;
    int endIndex = startIndex + 30;
    final symbols = context.read<StockListBloc>().state.symbols;
    startIndex = startIndex.clamp(0, symbols.length - 1);
    endIndex = endIndex.clamp(0, symbols.length);

    for (var symbol in symbols) {
      context.read<WebSocketBloc>().add(UnsubscribeFromSymbol(symbol.symbol));
    }

    for (var i = startIndex; i < endIndex; i++) {
      if (i < symbols.length) {
        context.read<WebSocketBloc>().add(SubscribeToSymbol(symbols[i].symbol));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(Constants.appTitle),
        ),
        body: Column(children: [
          SearchInputWidget(
            onTextChanged: (searchQuery) {
              context.read<StockListBloc>().add(FilterSymbols(searchQuery));
            },
          ),
          Expanded(
              child: BlocConsumer<StockListBloc, StockListState>(
            builder: (context, state) {
              if (state.loadStatus == LoadStatus.success) {
                final loadedSymbols = state.filteredSymbols;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      loadedSymbols.length + (state.hasMoreSymbols ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < loadedSymbols.length) {
                      final symbol = loadedSymbols[index];
                      return ListTile(
                        title: Text(symbol.description),
                        subtitle: BlocBuilder<WebSocketBloc, WebSocketState>(
                          builder: (context, state) {
                            if (state is WebSocketDataStateReceived) {
                              final priceMap = state.priceMap;
                              if (priceMap.containsKey(symbol.symbol)) {
                                final price = priceMap[symbol.symbol];
                                return Text('Price: ${price}');
                              }
                            } 
                              return Text('Price: 0.0');
                          },
                        ),
                        titleTextStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0),
                        subtitleTextStyle: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StockDetailScreen(symbol: symbol.symbol),
                            ),
                          )
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              } else if (state.loadStatus == LoadStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return const Center(
                  child: Text('No data found'),
                );
              }
            },
            listener: (BuildContext context, StockListState state) {
              if (state.loadStatus == LoadStatus.success) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateSubscriptions();
                });

              }
            },
            listenWhen: (previous, current) =>
                previous.loadStatus != current.loadStatus ||
                previous.isLoadingMore != true,
          ))
        ]));
  }
}
