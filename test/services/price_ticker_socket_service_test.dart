import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../mocks.mocks.dart';

void main() {
  group('WebSocketService', () {
    test('should connect to WebSocket', () {
      final mockWebSocketService = MockWebSocketService();
      when(mockWebSocketService.connectToWebSocket()).thenAnswer((_) => null);

      mockWebSocketService.connectToWebSocket();

      verify(mockWebSocketService.connectToWebSocket()).called(1);
    });

    test('should disconnect from WebSocket', () {
      final mockWebSocketService = MockWebSocketService();
      when(mockWebSocketService.dispose()).thenAnswer((_) => null);

      mockWebSocketService.dispose();

      verify(mockWebSocketService.dispose()).called(1);
    });

    test('should receive messages from WebSocket', () {
      final mockWebSocketService = MockWebSocketService();

      // Setup the mock to simulate receiving a message
      when(mockWebSocketService.getPrice(any)).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function(String);
        callback('Test message'); // Simulate receiving a message
      });

      String? receivedMessage; // Make it nullable
      // Pass a correctly typed callback to getPrice
      mockWebSocketService.getPrice((String? message) {
        receivedMessage = message; // Assign the received message
      } as String?);

      // The expect statement checks if the received message is as expected
      expect(receivedMessage, 'Test message');
    });

    test('should send messages to WebSocket', () {
      final mockWebSocketService = MockWebSocketService();
      when(mockWebSocketService.subscribeToSymbol(any)).thenAnswer((_) => null);

      mockWebSocketService.subscribeToSymbol('Hello WebSocket');

      verify(mockWebSocketService.subscribeToSymbol('Hello WebSocket'))
          .called(1);
    });

    test('should handle errors when connecting to WebSocket', () {
      final mockWebSocketService = MockWebSocketService();
      when(mockWebSocketService.connectToWebSocket())
          .thenThrow(Exception('Connection error'));

      expect(() => mockWebSocketService.connectToWebSocket(), throwsException);
    });

  });
}
