import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_equipment_rent/data/services/chat_service.dart';
import 'package:sport_equipment_rent/data/models/message_model.dart';
import 'package:sport_equipment_rent/data/models/chat_model.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final chatMessagesProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.read(chatServiceProvider).getMessages(chatId);
});

final userChatsProvider = StreamProvider.family<List<Chat>, String>((ref, userId) {
  return ref.read(chatServiceProvider).getUserChats(userId);
});