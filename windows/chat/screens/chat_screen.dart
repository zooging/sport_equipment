import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_equipment_rent/data/providers/chat_provider.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/data/models/message_model.dart';
import 'package:sport_equipment_rent/features/chat/widgets/message_bubble.dart';
import 'package:sport_equipment_rent/features/chat/widgets/message_input.dart';

class ChatScreen extends ConsumerWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    if (currentUser == null) return const Scaffold();

    final chatId = ref.read(chatServiceProvider).getChatId(currentUser.uid, receiverId);
    final messagesStream = ref.watch(chatMessagesProvider(chatId));

    return Scaffold(
      appBar: AppBar(
        title: Text(receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) {
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.uid;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Ошибка: $error')),
            ),
          ),
          MessageInput(
            chatId: chatId,
            receiverId: receiverId,
          ),
        ],
      ),
    );
  }
}