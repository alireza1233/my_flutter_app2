import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_list_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';   // <----- این خط اضافه شد
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatListProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (currentUser) {
          if (currentUser == null) return const Center(child: Text('نشست نامعتبر'));
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('هیچ چتی وجود ندارد'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showNewChatDialog(context, ref, currentUser),
                    child: const Text('شروع چت جدید'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: chat.otherUser.avatarUrl != null
                      ? NetworkImage(chat.otherUser.avatarUrl!)
                      : null,
                  child: chat.otherUser.avatarUrl == null
                      ? Text(chat.otherUser.name[0].toUpperCase())
                      : null,
                ),
                title: Text(chat.otherUser.name),
                subtitle: Text(
                  chat.lastMessage != null
                      ? (chat.lastMessage!.senderId == currentUser.id
                          ? 'من: '
                          : '') + chat.lastMessage!.text
                      : 'پیامی نیست',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (chat.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    if (chat.lastMessage != null)
                      Icon(
                        _statusIcon(chat.lastMessage!.status),
                        size: 16,
                        color: Colors.grey,
                      ),
                  ],
                ),
                onTap: () {
                  ref.read(chatListProvider.notifier).clearUnread(chat.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chat.id,
                        otherUser: chat.otherUser,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطا: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final user = currentUserAsync.value;
          if (user != null) _showNewChatDialog(context, ref, user);
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context, WidgetRef ref, User currentUser) {
    final authService = ref.read(authServiceProvider);
    final usersFuture = authService.getAllUsersExcept(currentUser.id);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('چت جدید'),
        content: FutureBuilder<List<User>>(
          future: usersFuture,
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final userList = snapshot.data!;
            return SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: CircleAvatar(child: Text(userList[i].name[0])),
                  title: Text(userList[i].name),
                  subtitle: Text(userList[i].phoneNumber),
                  onTap: () async {
                    final chatId = _generateChatId(currentUser.id, userList[i].id);
                    final existingChat = ref.read(chatListProvider).firstWhere(
                      (c) => c.id == chatId,
                      orElse: () => null as Chat,
                    );
                    if (existingChat == null) {
                      final newChat = Chat(
                        id: chatId,
                        otherUser: userList[i],
                        lastMessage: null,
                      );
                      await ref.read(chatListProvider.notifier).addOrUpdateChat(newChat);
                    }
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(chatId: chatId, otherUser: userList[i]),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _generateChatId(String user1, String user2) {
    final list = [user1, user2]..sort();
    return '${list[0]}_${list[1]}';
  }

  IconData _statusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.seen:
        return Icons.done_all;
    }
  }
}
