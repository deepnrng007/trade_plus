class Symbol {
  final String description;
  final String displaySymbol;
  final String symbol;

  Symbol({
    required this.description,
    required this.displaySymbol,
    required this.symbol,
  });

  factory Symbol.fromJson(Map<String, dynamic> json) {
    return Symbol(
      description: json['description'],
      displaySymbol: json['displaySymbol'],
      symbol: json['symbol'],
    );
  }
}
