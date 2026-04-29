import 'package:hive/hive.dart';
import 'user_model.dart';
import 'message_model.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 2)
class Chat {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final User otherUser;
  @HiveField(2)
  final Message? lastMessage;
  @HiveField(3)
  final int unreadCount;
  @HiveField(4)
  final bool isPinned;
  @HiveField(5)
  final bool isMuted;

  Chat({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
  });

  Chat copyWith({
    String? id,
    User? otherUser,
    Message? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
  }) {
    return Chat(
      id: id ?? this.id,
      otherUser: otherUser ?? this.otherUser,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}