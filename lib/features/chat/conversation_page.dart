import "package:flutter/material.dart";
import "package:notekey_app/features/widgets/topbar/base_scaffold.dart";
import "package:notekey_app/features/themes/colors.dart";

// Use-Cases
import "package:notekey_app/features/chat/functions/watch_messages.dart";
import "package:notekey_app/features/chat/functions/send_message.dart";
import "package:notekey_app/features/chat/functions/get_me.dart";
import "package:notekey_app/features/chat/functions/get_thread.dart";

// Models
import "package:notekey_app/features/chat/domain/chat_message.dart";
import "package:notekey_app/features/chat/domain/user_profile.dart";

class ConversationPage extends StatefulWidget {
  final String chatId;
  final String? title;

  const ConversationPage({
    super.key,
    required this.chatId,
    this.title,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late final Stream<List<ChatMessage>> _stream = watchMessages(widget.chatId);
  late final UserProfile me = getMe();
  late Future<String> _title = _loadTitle();

  Future<String> _loadTitle() async {
    if (widget.title != null) return widget.title!;
    final t = await getThread(widget.chatId);
    return t.title;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _title,
      builder: (_, snap) {
        final title = snap.data ?? "Chat";
        return BaseScaffold(
          appBarTitle: title,
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _stream,
                  builder: (_, snap) {
                    final msgs = snap.data ?? const <ChatMessage>[];
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: msgs.length,
                      itemBuilder: (_, i) {
                        final m = msgs[msgs.length - 1 - i];
                        final isMe = m.senderId == me.id;
                        return _MessageBubble(
                            text: m.text, isMe: isMe, time: m.sentAt);
                      },
                    );
                  },
                ),
              ),
              _MessageInput(
                onSend: (txt) => sendMessage(widget.chatId, txt),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime time;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? AppColors.dunkelbraun : Colors.white;
    final fg = isMe ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Text(text, style: TextStyle(color: fg, fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            _timeLabel(time),
            style: TextStyle(color: Colors.brown.shade400, fontSize: 11),
          ),
        ),
      ],
    );
  }

  String _timeLabel(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, "0");
    final mm = dt.minute.toString().padLeft(2, "0");
    return "$hh:$mm";
  }
}

class _MessageInput extends StatefulWidget {
  final void Function(String text) onSend;
  const _MessageInput({required this.onSend});

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    final txt = _ctrl.text;
    if (txt.trim().isEmpty) return;
    widget.onSend(txt);
    _ctrl.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: "Nachricht schreiben…",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: _send, child: const Text("Senden")),
          ],
        ),
      ),
    );
  }
}
