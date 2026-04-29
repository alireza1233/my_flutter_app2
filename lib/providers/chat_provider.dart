import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/encryption_service.dart';
import '../services/websocket_service.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import 'chat_list_provider.dart';

final encryptionServiceProvider = Provider((ref) => MockEncryptionService());
final webSocketProvider = Provider((ref) => MockWebSocketService());

final chatMessagesProvider = FutureProvider.family<List<Message>, String>((ref, chatId) async {
  final storage = ref.read(storageServiceProvider);
  return storage.getMessagesForChat(chatId);
});

final sendMessageProvider = FutureProvider.family<void, ({
  String chatId,
  String receiverId,
  String text,
  User currentUser,
})>((ref, params) async {
  final storage = ref.read(storageServiceProvider);
  final encryption = ref.read(encryptionServiceProvider);
  final ws = ref.read(webSocketProvider);
  final chatListNotifier = ref.read(chatListProvider.notifier);

  final encryptedText = await encryption.encrypt(params.text);
  final message = Message(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    chatId: params.chatId,
    senderId: params.currentUser.id,
    receiverId: params.receiverId,
    text: encryptedText,
    timestamp: DateTime.now(),
    status: MessageStatus.sending,
  );
  await storage.saveMessage(message);
  await chatListNotifier.updateLastMessage(params.chatId, message);
  ws.sendMessage(message);
});

final updateMessageStatusProvider = FutureProvider.family<void, ({String messageId, MessageStatus status})>(
  (ref, params) async {
    final storage = ref.read(storageServiceProvider);
    await storage.updateMessageStatus(params.messageId, params.status);
  },
);

// ********** اضافه شد: شنونده دائمی وب‌سوکت **********
final webSocketListenerProvider = Provider((ref) {
  final ws = ref.read(webSocketProvider);
  final storage = ref.read(storageServiceProvider);
  final chatListNotifier = ref.read(chatListProvider.notifier);

  ws.onMessage = (Message incomingMessage) async {
    // ذخیره پیام دریافتی در دیتابیس
    await storage.saveMessage(incomingMessage);
    // به‌روزرسانی آخرین پیام در لیست چت‌ها
    await chatListNotifier.updateLastMessage(incomingMessage.chatId, incomingMessage);
    // افزایش شمارنده نخوانده اگر کاربر گیرنده، کاربر فعلی است
    final currentUser = await storage.getCurrentUser();
    if (currentUser != null && incomingMessage.receiverId == currentUser.id) {
      await chatListNotifier.incrementUnread(incomingMessage.chatId);
    }
  };
  ws.connect();
  return ws;
});
// ************************************************