import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

// این provider همیشه یک کاربر تستی برمی‌گرداند – بدون نیاز به هیچ سرویسی
final currentUserProvider = Provider<User?>((ref) {
  return User(
    id: 'test_user_123',
    phoneNumber: '09123456789',
    name: 'کاربر تست',
    isOnline: true,
    lastSeen: DateTime.now(),
  );
});

// وضعیت احراز هویت – مستقیماً از currentUserProvider استفاده می‌کند
final authStateProvider = Provider<AsyncValue<User?>>((ref) {
  final user = ref.watch(currentUserProvider);
  return AsyncValue.data(user);
});

// این providerها فقط برای رفع خطای کامپایل باقی می‌مانند (اگر جایی استفاده شوند)
final authServiceProvider = Provider((ref) => null);
