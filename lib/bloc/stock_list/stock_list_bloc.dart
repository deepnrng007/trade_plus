// lib/blocs/stock_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trade_plus/repository/stock_repository.dart';
import 'package:trade_plus/utils/enums.dart';
import 'stock_list_event.dart';
import 'stock_list_state.dart';

class StockListBloc extends Bloc<StockListEvent, StockListState> {
  StockRepository stockRepository = StockRepository();

  StockListBloc() : super(StockListState()) {
    on<FetchSymbols>(_loadSymbols);
    on<LoadMoreSymbols>(_loadMoreSymbols);
    on<FilterSymbols>(_onSearchSymbols);
  }

  void _loadSymbols(FetchSymbols event, Emitter<StockListState> emit) async {
    emit(state.copyWith(loadStatus: LoadStatus.loading));
    final data = await stockRepository
        .fetchSymbols(
      limit: 20,
      offset: 0,
    )
        .then((response) {
      emit(state.copyWith(
        loadStatus: LoadStatus.success,
        symbols: response.toList(),
        filteredSymbols: response.skip(0).take(20).toList(),
      ));
    }).onError((error, stackTrace) {
      emit(state.copyWith(
          loadStatus: LoadStatus.failure, message: error.toString()));
    });
  }

  void _loadMoreSymbols(
      LoadMoreSymbols event, Emitter<StockListState> emit) async {
    if (state.isLoadingMore == true ||
        (state.loadStatus == LoadStatus.success && !state.hasMoreSymbols)) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    // await Future.delayed(const Duration(seconds: 3));
    final items = state.symbols.skip(event.offset).take(event.limit).toList();

    if (items.isEmpty) {
      emit(state.copyWith(
        loadStatus: LoadStatus.success,
        hasMoreSymbols: false,
        isLoadingMore: false,
      ));
      return;
    }
    emit(state.copyWith(
        loadStatus: LoadStatus.success,
        filteredSymbols: state.symbols + items,
        isLoadingMore: false,
        currentPage: state.currentPage + 1));
  }

  void _onSearchSymbols(FilterSymbols event, Emitter<StockListState> emit) {
    final currentState = state.loadStatus;

    if (currentState == LoadStatus.success) {
      final filtered = state.symbols
          .where((symbol) => symbol.description
              .toLowerCase()
              .contains(event.searchQuery.toLowerCase()))
          .toList();
      emit(state.copyWith(
          filteredSymbols: filtered, hasMoreSymbols: state.hasMoreSymbols));
    }
  }
}
