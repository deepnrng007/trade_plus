import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/services/network_services.dart';
import 'package:trade_plus/services/stocks_service.dart';
import 'package:trade_plus/utils/constants.dart';

class StockRepository {
  final StockApiService stockSymbolService = StockApiService(Constants.apiKey);
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<StockSymbol>> fetchStocks() async {
    try {
      var response = await _apiServices.getApi(
              '${Constants.stockSymbolEndpoint}&token=${Constants.apiKey}')
          as List<dynamic>;
      final stockList =
          response.map((item) => StockSymbol.fromJson(item)).toList();
      return stockList;
    } catch (e) {
      rethrow;
    }
  }
}
