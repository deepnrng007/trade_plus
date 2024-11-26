// lib/blocs/stock_list_state.dart

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/utils/enums.dart';

class StockListState extends Equatable {
  final List<StockSymbol> symbols;
  final bool isLoadingMore;
  final bool hasMoreSymbols;
  final List<StockSymbol> filteredSymbols;
  final LoadStatus loadStatus;
  final String message;
  final int currentPage;

  const StockListState(
      {this.symbols = const <StockSymbol>[],
      this.isLoadingMore = false,
      this.hasMoreSymbols = true,
      this.filteredSymbols = const <StockSymbol>[],
      this.loadStatus = LoadStatus.idle,
      this.message = '',
      this.currentPage = 1});

  factory StockListState.initial() {
    return StockListState(
        symbols: const [],
        isLoadingMore: false,
        hasMoreSymbols: true,
        filteredSymbols: const [],
        loadStatus: LoadStatus.idle,
        message: '',
        currentPage: 1);
  }

  StockListState copyWith(
      {List<StockSymbol>? symbols,
      bool? isLoadingMore,
      bool? hasMoreSymbols,
      List<StockSymbol>? filteredSymbols,
      LoadStatus? loadStatus,
      String? message,
      int? currentPage}) {
    return StockListState(
        symbols: symbols ?? this.symbols,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMoreSymbols: hasMoreSymbols ?? this.hasMoreSymbols,
        filteredSymbols: filteredSymbols ?? this.filteredSymbols,
        loadStatus: loadStatus ?? this.loadStatus,
        message: message ?? this.message,
        currentPage: currentPage ?? this.currentPage);
  }

  @override
  List<Object?> get props => [
        symbols,
        isLoadingMore,
        hasMoreSymbols,
        filteredSymbols,
        loadStatus,
        message,
        currentPage
      ];
}
