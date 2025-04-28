import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sport_equipment_rent/data/models/message_model.dart';
import 'package:sport_equipment_rent/data/models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Исправлен метод getChatId
  String getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Message.fromJson({
          'id': doc.id,
          ...doc.data(),
        })).toList());
  }

  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Chat.fromJson({
          'id': doc.id,
          ...doc.data(),
        })).toList());
  }

  Future<String?> getUsername(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['name'] as String?;
  }

  // Исправлен метод sendMessage
  Future<void> sendMessage(Message message, String chatId) async {
    try {
      // Создаем новое сообщение
      final messageRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toJson());

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      final currentUnreadCount = chatDoc.data()?['unreadCount'] ?? 0;


      // Обновляем последнее сообщение в чате
      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': message.text,
        'lastMessageTime': message.createdAt,
        'lastMessageSenderId': message.senderId,
        'participants': [message.senderId, message.receiverId],
        'unreadCount': currentUnreadCount + 1,
      }, SetOptions(merge: true));
    } catch (e) {
      throw 'Ошибка отправки сообщения: $e';
    }
  }

  Future<void> markChatAsRead(String chatId, String userId) async {
    try {
      // Обновляем счетчик непрочитанных
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({'unreadCount': 0});

      // Помечаем все сообщения как прочитанные
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw 'Ошибка при отметке сообщений как прочитанных: $e';
    }
  }
}