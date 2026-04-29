import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String phoneNumber;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String? avatarUrl;
  @HiveField(4)
  final String? bio;
  @HiveField(5)
  final bool isOnline;
  @HiveField(6)
  final DateTime? lastSeen;

  User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
  });

  User copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? avatarUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}