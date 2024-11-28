import 'dart:convert';

import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/utils/constants.dart';
import 'package:http/http.dart' as http;

class StockRepository {
  Future<List<StockSymbol>> fetchSymbols(
      {int limit = 50, int offset = 0}) async {
    try {
      final response = await http.get(Uri.parse(
          '${Constants.stockSymbolEndpoint}&token=${Constants.apiKey}'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body)
            as List<dynamic>; // Ensure it's treated as a List
        final listItems = jsonResponse
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
