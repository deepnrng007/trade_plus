import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trade_plus/models/Symbol.dart';
import 'package:trade_plus/utils/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  late WebSocketChannel channel;
  final Set<String> _subscribedSymbols = {};
  final StreamController _controller = StreamController.broadcast();
  final priceMap = <String, dynamic>{};

  Stream get priceStream => _controller.stream;

  WebSocketService() {
    connectToWebSocket();
  }

  void connectToWebSocket() {
    channel = IOWebSocketChannel.connect(
      Uri.parse('${Constants.webstreamUrl}${Constants.apiKey}'),
    );

    // Add connection status listener
    channel.stream.listen(
      (data) {
        try {
          final priceData = json.decode(data);
          if (priceData[Constants.type] == Constants.trade &&
              priceData[Constants.data] != null &&
              priceData[Constants.data].isNotEmpty) {
            for (dynamic priceItem in priceData[Constants.data]) {
              if (priceItem['s'] != null && priceItem['s'].isNotEmpty) {
                priceMap[priceItem['s']] = priceItem['p'];
              }
            }
            _controller.sink.add(Map.from(priceMap));
          } else if (priceData[Constants.type] == 'error') {
            print('Error from WebSocket: ${priceData[Constants.message]}');
          }
        } catch (e) {
          print('Error processing WebSocket data: $e');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _controller.sink.addError('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
        _controller.close();
      },
    );
  }

  // Getter to get cached price
  double? getPrice(String symbol) => priceMap[symbol];

  bool isSubscribed(String symbol) {
    return _subscribedSymbols.contains(symbol);
  }

  void unsubscribeFromSymbol(String symbol) {
    if (_subscribedSymbols.contains(symbol)) {
      _subscribedSymbols.remove(symbol);
      final message = json.encode({'type': 'unsubscribe', 'symbol': symbol});
      print('unsubscribing from: $message');
      channel.sink.add(message);
    }
  }

  void subscribeToSymbols(List<StockSymbol> symbols) {
    for (StockSymbol symbol in symbols) {
      if (isSubscribed(symbol.symbol)) {
        return;
      }
      subscribeToSymbol(symbol.symbol);
    }
  }

  void subscribeToSymbol(String symbol) {
    final message = json.encode({'type': 'subscribe', 'symbol': symbol});
    print('Subscribing to: $message');
    channel.sink.add(message);
    _subscribedSymbols.add(symbol);
  }

  void dispose() {
    channel.sink.close();
    _controller.close();
  }
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});
