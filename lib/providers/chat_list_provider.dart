import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

final storageServiceProvider = Provider((ref) => StorageService()); // الان Singleton است

final chatListProvider = StateNotifierProvider<ChatListNotifier, List<Chat>>((ref) {
  return ChatListNotifier(ref.read(storageServiceProvider));
});

class ChatListNotifier extends StateNotifier<List<Chat>> {
  final StorageService _storage;
  ChatListNotifier(this._storage) : super([]) {
    loadChats();
  }

  void loadChats() {
    final chats = _storage.getAllChats();
    chats.sort((a, b) {
      final timeA = a.lastMessage?.timestamp ?? DateTime(1970);
      final timeB = b.lastMessage?.timestamp ?? DateTime(1970);
      return timeB.compareTo(timeA);
    });
    state = chats;
  }

  Future<void> addOrUpdateChat(Chat chat) async {
    await _storage.saveChat(chat);
    loadChats();
  }

  Future<void> updateLastMessage(String chatId, Message message) async {
    final index = state.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final updatedChat = state[index].copyWith(lastMessage: message);
      await _storage.saveChat(updatedChat);
      loadChats();
    }
  }

  Future<void> incrementUnread(String chatId) async {
    final index = state.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final chat = state[index];
      final updated = chat.copyWith(unreadCount: chat.unreadCount + 1);
      await _storage.saveChat(updated);
      loadChats();
    }
  }

  Future<void> clearUnread(String chatId) async {
    final index = state.indexWhere((c) => c.id == chatId);
    if (index != -1) {
      final updated = state[index].copyWith(unreadCount: 0);
      await _storage.saveChat(updated);
      loadChats();
    }
  }
}