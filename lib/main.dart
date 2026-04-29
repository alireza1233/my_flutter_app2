import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'utils/theme.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';  // <----- اضافه شد

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // مقداردهی اولیه شنونده وب‌سوکت (فقط یک بار)
    ref.read(webSocketListenerProvider);
    
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      title: 'Telegram Clone',
      theme: appTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) {
          return authState.when(
            data: (user) => user != null ? const ChatListScreen() : const LoginScreen(),
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (_, __) => const LoginScreen(),
          );
        },
        '/login': (context) => const LoginScreen(),
        '/chats': (context) => const ChatListScreen(),
      },
    );
  }
}