import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_list_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/encryption_service.dart';
import '../widgets/message_input_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final User otherUser;
  const ChatScreen({super.key, required this.chatId, required this.otherUser});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _decryptedTextCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsSeen();
    });
  }

  void _markMessagesAsSeen() async {
    final storage = ref.read(storageServiceProvider);
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;
    final messages = storage.getMessagesForChat(widget.chatId);
    for (var msg in messages) {
      if (msg.receiverId == currentUser.id && msg.status != MessageStatus.seen) {
        await ref.read(updateMessageStatusProvider(
          (messageId: msg.id, status: MessageStatus.seen),
        ).future);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.avatarUrl != null
                  ? NetworkImage(widget.otherUser.avatarUrl!)
                  : null,
              child: widget.otherUser.avatarUrl == null
                  ? Text(widget.otherUser.name[0])
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUser.name),
                Text(
                  widget.otherUser.isOnline ? 'آنلاین' : 'آخرین بازدید دیروز',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // مرتب‌سازی صعودی (قدیمی‌ترین اول)
                final sortedMessages = List.of(messages)..sort((a,b)=>a.timestamp.compareTo(b.timestamp));
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: sortedMessages.length,
                  itemBuilder: (ctx, index) {
                    final msg = sortedMessages.reversed.toList()[index];
                    return FutureBuilder<String>(
                      future: _decryptText(msg.text),
                      builder: (ctx2, snapshot) {
                        final displayText = snapshot.data ?? '...';
                        final isMe = msg.senderId == currentUser?.id;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue[200] : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(displayText),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatTime(msg.timestamp),
                                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                                          ),
                                          if (isMe)
                                            Icon(
                                              _statusIcon(msg.status),
                                              size: 14,
                                              color: Colors.black54,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
          ),
          MessageInputBar(
            onSend: (text) async {
              final current = ref.read(currentUserProvider).value;
              if (current == null || text.trim().isEmpty) return;
              await ref.read(sendMessageProvider(
                chatId: widget.chatId,
                receiverId: widget.otherUser.id,
                text: text,
                currentUser: current,
              ).future);
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String> _decryptText(String cipher) async {
    if (_decryptedTextCache.containsKey(cipher)) {
      return _decryptedTextCache[cipher]!;
    }
    final encryption = ref.read(encryptionServiceProvider);
    try {
      final plain = await encryption.decrypt(cipher);
      _decryptedTextCache[cipher] = plain;
      return plain;
    } catch (_) {
      return '⚠️ رمزگشایی نشد';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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