import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 1)
class Message {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String chatId;
  @HiveField(2)
  final String senderId;
  @HiveField(3)
  final String receiverId;
  @HiveField(4)
  final String text;
  @HiveField(5)
  final DateTime timestamp;
  @HiveField(6)
  final MessageStatus status;
  @HiveField(7)
  final bool isDeleted;
  @HiveField(8)
  final String? mediaUrl;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sending,
    this.isDeleted = false,
    this.mediaUrl,
  });
}

@HiveType(typeId: 3)   // <----- اضافه شد
enum MessageStatus {
  @HiveField(0)
  sending,
  @HiveField(1)
  sent,
  @HiveField(2)
  delivered,
  @HiveField(3)
  seen,
}