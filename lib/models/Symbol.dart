class StockSymbol {
  final String description;
  final String displaySymbol;
  final String symbol;

  StockSymbol({
    required this.description,
    required this.displaySymbol,
    required this.symbol,
  });

  factory StockSymbol.fromJson(Map<String, dynamic> json) {
    return StockSymbol(
      description: json['description'],
      displaySymbol: json['displaySymbol'],
      symbol: json['symbol'],
    );
  }
}
