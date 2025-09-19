import "dart:async";
import "dart:math";

import "../domain/chat_message.dart";
import "../domain/chat_repository.dart";
import "../domain/chat_thread.dart";
import "../domain/user_profile.dart";

class InMemoryChatRepository implements ChatRepository {
  InMemoryChatRepository._internal() {
    _seed();
  }

  // Singleton
  static final InMemoryChatRepository instance =
      InMemoryChatRepository._internal();

  final _rnd = Random();

  // ---- Users ----
  final Map<String, UserProfile> _users = const {
    "me": UserProfile(id: "me", displayName: "Martin"),
    "u1": UserProfile(id: "u1", displayName: "Anna"),
    "u2": UserProfile(id: "u2", displayName: "Ben"),
    "u3": UserProfile(id: "u3", displayName: "Clara"),
  };

  UserProfile get _me => _users["me"]!;

  final Map<String, ChatThread> _threads = {};
  final Map<String, List<ChatMessage>> _messages = {};

  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  void _ensureController(String chatId) {
    _controllers.putIfAbsent(
      chatId,
      () => StreamController<List<ChatMessage>>.broadcast(),
    );
  }

  void _push(String chatId) {
    _ensureController(chatId);
    _controllers[chatId]!.add(List.unmodifiable(_messages[chatId] ?? const []));
  }

  String _rid(String pfx) =>
      "$pfx-${DateTime.now().microsecondsSinceEpoch}-${_rnd.nextInt(9999)}";

  void _bump(String chatId, String last, DateTime at) {
    final t = _threads[chatId]!;
    _threads[chatId] = t.copyWith(updatedAt: at, lastMessage: last);
  }

  void _seed() {
    final dmId = _rid("dm");
    final anna = _users["u1"]!;
    _threads[dmId] = ChatThread(
      id: dmId,
      isGroup: false,
      title: anna.displayName,
      participants: [_me, anna],
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      lastMessage: "Bis später!",
    );
    _messages[dmId] = [
      ChatMessage(
        id: _rid("m"),
        chatId: dmId,
        senderId: anna.id,
        text: "Hey Martin, alles klar?",
        sentAt: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
      ChatMessage(
        id: _rid("m"),
        chatId: dmId,
        senderId: _me.id,
        text: "Jo, unterwegs zur Probe.",
        sentAt: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        id: _rid("m"),
        chatId: dmId,
        senderId: anna.id,
        text: "Bis später!",
        sentAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];

    // Gruppe „Marianas“
    final gpId = _rid("gp");
    final ben = _users["u2"]!;
    final clara = _users["u3"]!;
    _threads[gpId] = ChatThread(
      id: gpId,
      isGroup: true,
      title: "Marianas",
      participants: [_me, ben, clara],
      updatedAt: DateTime.now().subtract(const Duration(minutes: 8)),
      lastMessage: "Setlist passt 😎",
    );
    _messages[gpId] = [
      ChatMessage(
        id: _rid("m"),
        chatId: gpId,
        senderId: ben.id,
        text: "Proberaum heute 19:30?",
        sentAt: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
      ChatMessage(
        id: _rid("m"),
        chatId: gpId,
        senderId: _me.id,
        text: "Yes. Ich bringe Notenständer.",
        sentAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      ChatMessage(
        id: _rid("m"),
        chatId: gpId,
        senderId: clara.id,
        text: "Setlist passt 😎",
        sentAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ];
  }

  // ChatRepository

  @override
  Future<void> sendMessage(ChatMessage message) async {
    if (message.text.trim().isEmpty) return;
    _messages.putIfAbsent(message.chatId, () => []);
    _messages[message.chatId]!.add(message);
    _bump(message.chatId, message.text, message.sentAt);
    _push(message.chatId);

    // kleine Fake-Antwort
    await Future.delayed(const Duration(milliseconds: 450));
    final t = _threads[message.chatId];
    if (t == null) return;
    final others =
        t.participants.where((p) => p.id != message.senderId).toList();
    if (others.isEmpty) return;
    final responder = others[_rnd.nextInt(others.length)];
    final reply = ChatMessage(
      id: _rid("m"),
      chatId: message.chatId,
      senderId: responder.id,
      text: _autoReply(message.text),
      sentAt: DateTime.now(),
    );
    _messages[message.chatId]!.add(reply);
    _bump(message.chatId, reply.text, reply.sentAt);
    _push(message.chatId);
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String chatId) {
    _ensureController(chatId);
    Future.microtask(() => _push(chatId));
    return _controllers[chatId]!.stream;
  }

  @override
  Future<List<ChatMessage>> getHistory(String chatId, {int limit = 50}) async {
    final list = _messages[chatId] ?? const <ChatMessage>[];
    if (list.length <= limit) return List.unmodifiable(list);
    return List.unmodifiable(list.sublist(list.length - limit));
  }

  @override
  Future<List<String>> fetchRecentChatIds({int limit = 10}) async {
    final threads = _threads.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return threads.take(limit).map((t) => t.id).toList();
  }

  @override
  Future<ChatThread> getThread(String chatId) async {
    final t = _threads[chatId];
    if (t == null) throw StateError("Thread $chatId nicht gefunden");
    return t;
  }

  @override
  Future<String> ensureDirectThread(String otherUserId) async {
    final existing = _threads.values.where((t) => !t.isGroup).firstWhere(
          (t) => t.participants
              .map((e) => e.id)
              .toSet()
              .containsAll({_me.id, otherUserId}),
          orElse: () => ChatThread(
            id: "",
            isGroup: false,
            title: "",
            participants: const [],
            updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );
    if (existing.id.isNotEmpty) return existing.id;

    final other = _users[otherUserId];
    if (other == null) {
      throw StateError("User $otherUserId nicht gefunden");
    }

    final id = _rid("dm");
    _threads[id] = ChatThread(
      id: id,
      isGroup: false,
      title: other.displayName,
      participants: [_me, other],
      updatedAt: DateTime.now(),
    );
    _messages[id] = [];
    return id;
  }

  @override
  Future<String> createGroupThread(String name, List<String> memberIds) async {
    final id = _rid("gp");
    final members = <UserProfile>[_me];
    for (final m in memberIds) {
      final u = _users[m];
      if (u == null) {
        throw StateError("User $m nicht gefunden");
      }
      members.add(u);
    }

    _threads[id] = ChatThread(
      id: id,
      isGroup: true,
      title: name,
      participants: members,
      updatedAt: DateTime.now(),
    );
    _messages[id] = [];
    return id;
  }

  @override
  UserProfile currentUser() => _me;

  @override
  List<UserProfile> allUsers() => _users.values.toList(growable: false);

  String _autoReply(String _) {
    const canned = [
      "Klingt gut!",
      "Erzähl mehr",
      "Bin dabei",
      "Heute eher später…",
      "Cool, machen wir so.",
    ];
    return canned[_rnd.nextInt(canned.length)];
  }
}
