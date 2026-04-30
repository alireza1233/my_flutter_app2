import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/debug_screen.dart'; // اضافه شد
import 'utils/theme.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final storage = StorageService();
    await storage.init();
    print('✅ Storage initialized');
  } catch (e) {
    debugPrint('❌ Storage initialization failed: $e');
    // برنامه همچنان اجرا می‌شود
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ========== گناهکار دوم: غیرفعال کردن WebSocket ==========
    // ref.read(webSocketListenerProvider); // کامنت شد

    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      title: 'Telegram Clone',
      theme: appTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) {
          return authState.when(
            data: (user) {
              print('📱 Auth state data: user=${user?.id}');
              return user != null ? const ChatListScreen() : const LoginScreen();
            },
            loading: () {
              print('⏳ Auth is loading...');
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
            error: (err, stack) {
              print('💥 Auth error: $err');
              print(stack);
              // نمایش صفحه دیباگ با خطا
              return DebugScreen(logs: ['Error: $err', 'Stack: $stack']);
            },
          );
        },
        '/login': (context) => const LoginScreen(),
        '/chats': (context) => const ChatListScreen(),
        '/debug': (context) => const DebugScreen(), // دسترسی مستقیم به دیباگ
      },
    );
  }
}
