import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:notekey_app/features/chat/chat_service.dart';
import 'package:notekey_app/features/themes/colors.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  final _auth = FirebaseAuth.instance;

  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: text,
      );
      _messageController.clear();
      _scrollToEnd();
    } catch (e) {
      debugPrint('Fehler beim Senden der Nachricht: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Senden der Nachricht')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _pickImageAndSend(ImageSource source) async {
    if (_sending) return;

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (picked == null) return;

      setState(() => _sending = true);

      final file = File(picked.path);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(widget.chatId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(file);
      final imageUrl = await storageRef.getDownloadURL();

      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: '',
        imageUrl: imageUrl,
      );

      _scrollToEnd();
    } catch (e) {
      debugPrint('Fehler beim Senden des Bildes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Senden des Bildes')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.hellbeige,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 140,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ImageSourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Mediathek',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageAndSend(ImageSource.gallery);
                      },
                    ),
                    _ImageSourceButton(
                      icon: Icons.photo_camera_rounded,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageAndSend(ImageSource.camera);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: AppColors.hellbeige,
        title: Text(
          widget.otherUserName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.messageStream(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.brown),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Noch keine Nachrichten',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // nach dem ersten Build runter scrollen
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToEnd();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final isMe = data['senderId'] == currentUser?.uid;

                    final String text = (data['text'] ?? '') as String;
                    final String imageUrl =
                        (data['imageUrl'] ?? '') as String? ?? '';

                    return _MessageBubble(
                      isMe: isMe,
                      text: text,
                      imageUrl: imageUrl.isEmpty ? null : imageUrl,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 8),
        child: Row(
          children: [
            // Kamera-Button links im Feld
            GestureDetector(
              onTap: _sending ? null : _showImageSourceSheet,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.hellbeige,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: AppColors.dunkelbraun,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Textfeld
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.hellbeige,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(
                    color: AppColors.dunkelbraun,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nachricht schreiben...',
                    hintStyle: TextStyle(
                      color: Colors.brown,
                      fontSize: 15,
                    ),
                  ),
                  onSubmitted: (_) => _sendTextMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Senden-Button
            GestureDetector(
              onTap: _sending ? null : _sendTextMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      _sending ? Colors.brown.shade300 : AppColors.dunkelbraun,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.hellbeige,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final String? imageUrl;

  const _MessageBubble({
    required this.isMe,
    required this.text,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isMe ? AppColors.goldbraun : AppColors.hellbeige.withOpacity(0.9);
    final textColor = isMe ? Colors.white : AppColors.dunkelbraun;

    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (text.isNotEmpty) const SizedBox(height: 6),
            ],
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.dunkelbraun,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.hellbeige, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.dunkelbraun,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
