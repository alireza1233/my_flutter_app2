import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class DebugScreen extends StatelessWidget {
  final List<String> logs;
  const DebugScreen({super.key, this.logs = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Catcher - Live Errors'),
        backgroundColor: Colors.red,
      ),
      body: logs.isEmpty
          ? const Center(child: Text('هیچ خطایی ثبت نشده است'))
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (ctx, i) => Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(logs[i]),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
