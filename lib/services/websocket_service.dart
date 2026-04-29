import 'dart:async';
import '../models/message_model.dart';

typedef OnMessageReceived = void Function(Message message);

class MockWebSocketService {
  static final MockWebSocketService _instance = MockWebSocketService._internal();
  factory MockWebSocketService() => _instance;
  MockWebSocketService._internal();

  OnMessageReceived? onMessage;
  Timer? _simulationTimer;

  void connect() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {});
  }

  void sendMessage(Message message) {
    Future.delayed(const Duration(milliseconds: 500), () {
      final updated = Message(
        id: message.id,
        chatId: message.chatId,
        senderId: message.senderId,
        receiverId: message.receiverId,
        text: message.text,
        timestamp: message.timestamp,
        status: MessageStatus.sent,
      );
      onMessage?.call(updated);
    });
  }

  void disconnect() {
    _simulationTimer?.cancel();
  }
}