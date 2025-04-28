import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/providers/chat_provider.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/features/chat/screens/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    if (currentUser == null) return const Scaffold();

    final chatService = ref.watch(chatServiceProvider);
    final chatsStream = chatService.getUserChats(currentUser.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
      ),
      body: StreamBuilder(
        stream: chatsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!;

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64.r,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  const Text('У вас пока нет сообщений'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.participants
                  .firstWhere((id) => id != currentUser.uid);
              final hasUnread = chat.unreadCount > 0 &&
                  chat.lastMessageSenderId != currentUser.uid;

              return FutureBuilder<String?>(
                future: chatService.getUsername(otherUserId),
                builder: (context, snapshot) {
                  final username = snapshot.data ?? 'Пользователь';

                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          child: Text(username[0].toUpperCase()),
                        ),
                        if (hasUnread)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                chat.unreadCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      username,
                      style: TextStyle(
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeago.format(chat.lastMessageTime, locale: 'ru'),
                          style: TextStyle(
                            color: hasUnread ?
                            Theme.of(context).primaryColor : Colors.grey,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (hasUnread) {
                        chatService.markChatAsRead(chat.id, currentUser.uid);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: otherUserId,
                            receiverName: username,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}