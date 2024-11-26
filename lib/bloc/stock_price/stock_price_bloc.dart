import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:trade_plus/bloc/stock_price/stock_price_event.dart';
import 'package:trade_plus/bloc/stock_price/stock_price_state.dart';
import 'package:trade_plus/utils/constants.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  late final IOWebSocketChannel _channel;
  final Set<String> _subscribedSymbols = {};
  final Map<String, double> _priceMap = {};

  WebSocketBloc() : super(WebSocketInitial()) {
    _connectToWebSocket();
    on<SubscribeToSymbol>(_onSubscribeToSymbol);
    on<UnsubscribeFromSymbol>(_onUnsubscribeFromSymbol);
    on<WebSocketDataEventReceived>(_onWebSocketDataEventReceived);
    on<WebSocketErrorOccurred>(_onErrorOccured);
  }

  void _connectToWebSocket() {
    _channel = IOWebSocketChannel.connect(
      Uri.parse('${Constants.webstreamUrl}${Constants.apiKey}'),
    );

    _channel.stream.listen(
      (data) {
        try {
          final priceData = json.decode(data);
          if (priceData[Constants.type] == Constants.trade &&
              priceData[Constants.data] != null &&
              priceData[Constants.data].isNotEmpty) {
            for (var priceItem in priceData[Constants.data]) {
              if (priceItem['s'] != null && priceItem['s'].isNotEmpty) {
                _priceMap[priceItem['s']] = priceItem['p'];
              }
            }
            // emit(WebSocketDataStateReceived(Map.from(_priceMap)));
            add(WebSocketDataEventReceived(_priceMap));
          }
        } catch (e) {
          add(WebSocketErrorOccurred('Error processing WebSocket data: $e'));
        }
      },
      onError: (error) {
        add(WebSocketErrorOccurred('WebSocket error: $error'));
      },
    );
  }

  void _onSubscribeToSymbol(
      SubscribeToSymbol event, Emitter<WebSocketState> emit) {
    print("WEBSOCKET-subscribingtosymbol ${event.symbol}");
    if (!_subscribedSymbols.contains(event.symbol)) {
      _subscribedSymbols.add(event.symbol);
      _channel.sink
          .add(json.encode({'type': 'subscribe', 'symbol': event.symbol}));
    }
  }

  void _onUnsubscribeFromSymbol(
      UnsubscribeFromSymbol event, Emitter<WebSocketState> emit) {
    print("WEBSOCKET-unsubscribingtosymbol ${event.symbol}");
    if (_subscribedSymbols.contains(event.symbol)) {
      _subscribedSymbols.remove(event.symbol);
      _channel.sink
          .add(json.encode({'type': 'unsubscribe', 'symbol': event.symbol}));
    }
  }

  void _onWebSocketDataEventReceived(
      WebSocketDataEventReceived event, Emitter<WebSocketState> emit) {
    emit(WebSocketDataStateReceived(Map.from(event.priceMap)));
  }

  void _onErrorOccured(
      WebSocketErrorOccurred event, Emitter<WebSocketState> emit) {
    emit(WebSocketError(event.message));
  }

  @override
  Future<void> close() {
    _channel.sink.close();
    return super.close();
  }
}
