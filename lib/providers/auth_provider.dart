// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// یک AuthService ساختگی برای جلوگیری از خطا
class MockAuthService extends AuthService {
  @override
  Future<List<User>> getAllUsersExcept(String currentUserId) async {
    // برگرداندن یک لیست خالی (یا می‌توان چند کاربر تستی ساخت)
    return [];
  }
}

final authServiceProvider = Provider((ref) => MockAuthService());

// FutureProvider برای کاربر فعلی (برای استفاده در ChatListScreen)
final currentUserProvider = FutureProvider<User?>((ref) async {
  // شبیه‌سازی کاربر تستی
  return User(
    id: 'test_user_123',
    phoneNumber: '09123456789',
    name: 'کاربر تست',
    isOnline: true,
    lastSeen: DateTime.now(),
  );
});

// StateNotifierProvider برای مدیریت وضعیت ورود/خروج
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final testUser = User(
      id: 'test_user_123',
      phoneNumber: '09123456789',
      name: 'کاربر تست',
      isOnline: true,
      lastSeen: DateTime.now(),
    );
    state = AsyncValue.data(testUser);
  }

  Future<void> login(String phone) async {
    state = const AsyncValue.loading();
    try {
      final testUser = User(
        id: 'test_user_123',
        phoneNumber: phone,
        name: 'کاربر تست',
        isOnline: true,
        lastSeen: DateTime.now(),
      );
      state = AsyncValue.data(testUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    // در حالت تست، فقط کاربر را حذف می‌کنیم
    state = const AsyncValue.data(null);
  }
}
