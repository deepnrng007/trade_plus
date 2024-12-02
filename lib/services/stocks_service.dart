import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/utils/constants.dart';

class StockApiService {
  final String apiKey;

  StockApiService(this.apiKey);

  // Method to fetch symbols with pagination
  Future<List<StockSymbol>> fetchSymbols(
      {int limit = 50, int offset = 0}) async {
    try {
      final response = await http
          .get(Uri.parse('${Constants.stockSymbolEndpoint}&token=$apiKey'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body)
            as List<dynamic>; // Ensure it's treated as a List
        final listItems = jsonResponse
            .skip(offset)
            .take(limit)
            .map((item) => StockSymbol.fromJson(item))
            .toList();

        return listItems;
      } else {
        throw Exception('Failed to load stock symbols');
      }
    } catch (e) {
      print('Error fetching symbols: $e');
      throw Exception('Failed to load stock symbols: $e');
    }
  }
}

final stockApiServiceProvider = Provider<StockApiService>((ref) {
  return StockApiService("");
});
