// lib/blocs/stock_list_event.dart

import 'package:equatable/equatable.dart';

abstract class StockListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchSymbols extends StockListEvent {}

class LoadMoreSymbols extends StockListEvent {
  final int limit; // default page number
  final int offset ; // default page size

  LoadMoreSymbols({required this.limit, required this.offset});
}

class FilterSymbols extends StockListEvent {
  final String searchQuery;

  FilterSymbols(this.searchQuery);
}
