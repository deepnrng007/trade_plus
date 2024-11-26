import 'package:equatable/equatable.dart';

abstract class WebSocketState extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class WebSocketInitial extends WebSocketState {}

class WebSocketLoading extends WebSocketState {}

class WebSocketDataStateReceived extends WebSocketState {
  final Map<String, dynamic> priceMap;
  WebSocketDataStateReceived(this.priceMap);

  // @override
  List<Object?> get props => [priceMap];
}

class WebSocketError extends WebSocketState {
  final String message;
  WebSocketError(this.message);
}
