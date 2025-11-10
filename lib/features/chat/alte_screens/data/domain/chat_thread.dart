import 'user_profile.dart';

class ChatThread {
  final String id;
  final bool isGroup;
  final String title;
  final List<UserProfile> participants;
  final DateTime updatedAt;
  final String? lastMessage;

  const ChatThread({
    required this.id,
    required this.isGroup,
    required this.title,
    required this.participants,
    required this.updatedAt,
    this.lastMessage,
  });

  ChatThread copyWith({
    String? title,
    List<UserProfile>? participants,
    DateTime? updatedAt,
    String? lastMessage,
  }) {
    return ChatThread(
      id: id,
      isGroup: isGroup,
      title: title ?? this.title,
      participants: participants ?? this.participants,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
