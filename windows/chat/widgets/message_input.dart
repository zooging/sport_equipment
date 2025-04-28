import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_equipment_rent/data/providers/chat_provider.dart';
import 'package:sport_equipment_rent/data/providers/auth_provider.dart';
import 'package:sport_equipment_rent/data/models/message_model.dart';
import 'package:sport_equipment_rent/data/providers/storage_provider.dart';

class MessageInput extends ConsumerStatefulWidget {
  final String chatId;
  final String receiverId;

  const MessageInput({
    super.key,
    required this.chatId,
    required this.receiverId,
  });

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final text = _textController.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) return;

    try {
      final message = Message(
        id: '',
        senderId: currentUser.uid,
        receiverId: widget.receiverId,
        text: text,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await ref.read(chatServiceProvider).sendMessage(
        message,
        widget.chatId,
      );

      _textController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);

    try {
      final imageUrl = await ref.read(storageServiceProvider)
          .uploadChatImage(File(pickedFile.path));

      await _sendMessage(imageUrl: imageUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки изображения: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoading ? null : _pickImage,
            icon: _isLoading
                ? SizedBox(
              width: 24.r,
              height: 24.r,
              child: const CircularProgressIndicator(),
            )
                : const Icon(Icons.image),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Сообщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
              ),
              maxLines: 4,
              minLines: 1,
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () => _sendMessage(),
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}