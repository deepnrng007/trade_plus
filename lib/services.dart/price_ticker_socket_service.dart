import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:trade_plus/models/Symbol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  final String _apiKey = 'cscfm5hr01qpohrs3obgcscfm5hr01qpohrs3oc0';
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
      Uri.parse('wss://ws.finnhub.io?token=$_apiKey'),
    );

    // Add connection status listener
    channel.stream.listen(
      (data) {
        final priceData = json.decode(data);
        if (priceData['type'] == 'trade' && priceData['data'] != null && priceData['data'].isNotEmpty) {
          for(dynamic priceItem in priceData['data']){
            if(priceItem['s'] != null && priceItem['s'].isNotEmpty){
              priceMap[priceItem['s']] = priceItem['p'];
            }
          }
          print("responsspnsssss $priceMap");
          _controller.sink.add(Map.from(priceMap));
        } else if (priceData['type'] == 'error') {
          print(priceData['message']);
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }

  double? getPrice(String symbol) => priceMap[symbol]; // Get cached price

bool isSubscribed(String symbol) {
    return _subscribedSymbols.contains(symbol);
  }

void unsubscribeFromSymbol(String symbol) {
    if (_subscribedSymbols.contains(symbol)) {
      _subscribedSymbols.remove(symbol);
        final message =
          json.encode({'type': 'unsubscribe', 'symbol': symbol});
      print('unnunununSubscribing to: $message');
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
      final message =
          json.encode({'type': 'subscribe', 'symbol': symbol});
      print('Subscribing to: $message');
      channel.sink.add(message);
      _subscribedSymbols.add(symbol);
  }

  void dispose() {
    channel.sink.close();
    _controller.close();
  }
}


// Create providers for both services
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService(); // Replace with your actual implementation
});


// class WebSocketService {
//   final String _apiKey = 'cscfm5hr01qpohrs3obgcscfm5hr01qpohrs3oc0';
//   late WebSocketChannel channel;
//   final StreamController _controller = StreamController.broadcast();

//   Stream get priceStream => _controller.stream;

//   WebSocketService() {
//     connectToWebSocket();
//   }

//   void connectToWebSocket() {
//     channel = IOWebSocketChannel.connect(
//       Uri.parse('wss://ws.finnhub.io?token=$_apiKey'),
//     );

//     channel.stream.listen(
//       (data) {
//         final response = json.decode(data);
        
//         if (response is Map && response.containsKey('data') && response['type'] != 'ping') {
//           print('WebSocket received: ${response['data'][0]}');
//           _controller.add(response['data'][0]['p']);
//         } else if (response['type'] == 'error') {
//           print(response['message']);
//         }
//       },
//       onError: (error) {
//         print('WebSocket error: $error');
//         _controller.addError(error);  // Add error to StreamController
//       },
//       onDone: () {
//         print('WebSocket connection closed');
//         _controller.close();  // Close StreamController when done
//       },
//     );
//   }

//   void subscribeToSymbols(List<StockSymbol> symbols) {
//     for (StockSymbol symbol in symbols) {
//       final message = json.encode({'type': 'subscribe', 'symbol': symbol.symbol});
//       print('Subscribing to: $message');
//       channel.sink.add(message);
//     }
//   }

//   void dispose() {
//     _controller.close();
//     channel.sink.close();
//   }
// }
