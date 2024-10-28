
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String get apiKey => dotenv.env['API_KEY'] ?? 'default_api_key';
  static const String appTitle= "Real-Time Stock Prices";
  static const String stockSymbolEndpoint= "https://finnhub.io/api/v1/forex/symbol?exchange=oanda";
  static const String webstreamUrl= "wss://ws.finnhub.io?token=";
  static const String type= "type";
  static const String data= "data";
  static const String trade= "trade";
  static const String message= "message";

}
