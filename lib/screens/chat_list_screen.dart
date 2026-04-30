import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // دیتای ساختگی برای نمایش چند چت
    final dummyChats = [
      {
        'name': 'علی رضایی',
        'lastMessage': 'سلام، چطوری؟',
        'time': '۱۰:۲۳',
        'unread': 2,
      },
      {
        'name': 'سارا محمدی',
        'lastMessage': 'جلسه ساعت ۳',
        'time': 'دیروز',
        'unread': 0,
      },
      {
        'name': 'رضا کریمی',
        'lastMessage': 'مرسی بابت کمک',
        'time': 'دیروز',
        'unread': 0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // موقتاً کاری نمی‌کند
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('خروج موقتاً غیرفعال است')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyChats.length,
        itemBuilder: (context, index) {
          final chat = dummyChats[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(chat['name']![0]),
            ),
            title: Text(chat['name']!),
            subtitle: Text(chat['lastMessage']!),
            trailing: chat['unread']! > 0
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat['unread']}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                : Text(chat['time']!),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('صفحه چت در حال توسعه است')),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('شروع چت جدید در حال توسعه')),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
