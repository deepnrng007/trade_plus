import 'package:equatable/equatable.dart';

abstract class WebSocketEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SubscribeToSymbol extends WebSocketEvent {
  final String symbol;
  SubscribeToSymbol(this.symbol);
}

class UnsubscribeFromSymbol extends WebSocketEvent {
  final String symbol;
  UnsubscribeFromSymbol(this.symbol);
}

class WebSocketErrorOccurred extends WebSocketEvent {
  final String message;
  WebSocketErrorOccurred(this.message);
}

class WebSocketDataEventReceived extends WebSocketEvent {
  final Map<String, dynamic> priceMap;
  WebSocketDataEventReceived(this.priceMap);
}
