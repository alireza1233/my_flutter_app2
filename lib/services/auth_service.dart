import 'package:hive/hive.dart';
import 'storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  final StorageService _storage = StorageService(); // الان Singleton است

  Future<User?> loginWithPhone(String phoneNumber) async {
    final allUsersBox = Hive.box<User>('user_box');
    User? existing = allUsersBox.values.firstWhere(
      (u) => u.phoneNumber == phoneNumber,
      orElse: () => null as User,
    );
    if (existing != null) {
      await _storage.saveCurrentUser(existing);
      return existing;
    }
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phoneNumber: phoneNumber,
      name: 'User ${phoneNumber.substring(phoneNumber.length - 4)}',
      avatarUrl: null,
      isOnline: true,
      lastSeen: DateTime.now(),
    );
    await _storage.saveCurrentUser(newUser);
    await allUsersBox.put(newUser.id, newUser);
    return newUser;
  }

  Future<void> logout() async {
    await _storage.deleteCurrentUser();
  }

  Future<User?> getCurrentUser() => _storage.getCurrentUser();

  Future<List<User>> getAllUsersExcept(String currentUserId) async {
    final box = Hive.box<User>('user_box');
    return box.values.where((u) => u.id != currentUserId).toList();
  }

  Future<User> getUserById(String id) async {
    final box = Hive.box<User>('user_box');
    return box.get(id)!;
  }
}