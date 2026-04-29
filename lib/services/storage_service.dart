import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String userBox = 'user_box';
  static const String chatsBox = 'chats_box';
  static const String messagesBox = 'messages_box';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(ChatAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(MessageStatusAdapter());
    await Hive.openBox<User>(userBox);
    await Hive.openBox<Chat>(chatsBox);
    await Hive.openBox<Message>(messagesBox);
    _initialized = true;
  }

  Future<void> saveCurrentUser(User user) async {
    await _secureStorage.write(key: 'current_user_id', value: user.id);
    final box = Hive.box<User>(userBox);
    await box.put(user.id, user);
  }

  Future<User?> getCurrentUser() async {
    final userId = await _secureStorage.read(key: 'current_user_id');
    if (userId == null) return null;
    final box = Hive.box<User>(userBox);
    return box.get(userId);
  }

  Future<void> deleteCurrentUser() async {
    await _secureStorage.delete(key: 'current_user_id');
  }

  Future<void> saveChat(Chat chat) async {
    final box = Hive.box<Chat>(chatsBox);
    await box.put(chat.id, chat);
  }

  List<Chat> getAllChats() {
    final box = Hive.box<Chat>(chatsBox);
    return box.values.toList();
  }

  Future<void> deleteChat(String chatId) async {
    final box = Hive.box<Chat>(chatsBox);
    await box.delete(chatId);
  }

  Future<void> saveMessage(Message message) async {
    final box = Hive.box<Message>(messagesBox);
    await box.put(message.id, message);
  }

  List<Message> getMessagesForChat(String chatId) {
    final box = Hive.box<Message>(messagesBox);
    return box.values.where((msg) => msg.chatId == chatId).toList();
  }

  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    final box = Hive.box<Message>(messagesBox);
    final msg = box.get(messageId);
    if (msg != null) {
      final updated = Message(
        id: msg.id,
        chatId: msg.chatId,
        senderId: msg.senderId,
        receiverId: msg.receiverId,
        text: msg.text,
        timestamp: msg.timestamp,
        status: status,
        isDeleted: msg.isDeleted,
        mediaUrl: msg.mediaUrl,
      );
      await box.put(messageId, updated);
    }
  }
}