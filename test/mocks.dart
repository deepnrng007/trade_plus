import 'package:mockito/annotations.dart';
import 'package:trade_plus/services/price_ticker_socket_service.dart';
import 'package:trade_plus/services/stocks_service.dart';

// Tell Mockito to generate mock classes for these services
@GenerateMocks([StockApiService, WebSocketService])
void main() {}
