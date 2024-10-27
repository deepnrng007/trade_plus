import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:trade_plus/models/Symbol.dart';

class StockApiService {
  final String apiKey;
  final String baseUrl =
      'https://finnhub.io/api/v1/forex/symbol?exchange=oanda';

  StockApiService(this.apiKey);

  // Method to fetch symbols with pagination
  Future<List<StockSymbol>> fetchSymbols({int limit = 50, int offset = 0}) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl&token=$apiKey'));
    print("objectlskdlksdls $limit, $offset");
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as List<dynamic>; // Ensure it's treated as a List
      final listItems = jsonResponse
          .skip(offset)
          .take(limit)
          .map((item) => StockSymbol.fromJson(item)).toList();

      return listItems;
    } else {
      throw Exception('Failed to load stock symbols');
    }
  } catch (e) {
    print('Error fetching symbols: $e');
    rethrow;
  }
}
}

final stockApiServiceProvider = Provider<StockApiService>((ref) {
  return StockApiService(""); // Replace with your actual implementation
});

