import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 80),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'شماره تلفن',
                prefixText: '+98 ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final phone = _phoneController.text.trim();
                if (phone.isNotEmpty) {
                  await ref.read(authStateProvider.notifier).login(phone);
                  if (mounted && ref.read(authStateProvider).hasValue && ref.read(authStateProvider).value != null) {
                    Navigator.pushReplacementNamed(context, '/chats');
                  }
                }
              },
              child: const Text('ورود'),
            ),
            if (authState.isLoading) const CircularProgressIndicator(),
            if (authState.hasError)
              Text('خطا: ${authState.error}', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}