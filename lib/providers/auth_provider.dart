import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider((ref) => AuthService());

final currentUserProvider = FutureProvider<User?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  return await auth.getCurrentUser();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  // اصلاح شده: برگرداندن کاربر تستی بدون نیاز به دیتابیس
  Future<void> _loadUser() async {
    try {
      // ساخت کاربر تستی ساده برای تست فرانت‌اند
      final testUser = User(
        id: 'test_user_123',
        phoneNumber: '09123456789',
        name: 'کاربر تست',
        isOnline: true,
        lastSeen: DateTime.now(),
      );
      state = AsyncValue.data(testUser);
      print('✅ کاربر تستی با موفقیت ساخته شد: ${testUser.name}');
    } catch (e, stack) {
      print('❌ خطا در ساخت کاربر تستی: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(String phone) async {
    state = const AsyncValue.loading();
    try {
      // برای سادگی، همان کاربر تستی برگردانده می‌شود
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
    state = const AsyncValue.data(null);
  }
}
