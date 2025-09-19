import "package:flutter/material.dart";
import "package:notekey_app/features/widgets/topbar/base_scaffold.dart";
import "package:notekey_app/features/themes/colors.dart";

// Use-Cases
import "package:notekey_app/features/chat/functions/fetch_recent_chats.dart";
import "package:notekey_app/features/chat/functions/get_thread.dart";

// Models
import "package:notekey_app/features/chat/domain/chat_thread.dart";

import "conversation_page.dart";

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  late Future<List<ChatThread>> _future = fetchRecentChats(limit: 30);

  Future<void> _reload() async {
    final list = await fetchRecentChats(limit: 30);
    if (!mounted) return;
    setState(() => _future = Future.value(list));
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarTitle: "Chat",
      body: Column(
        children: [
          Container(
            color: AppColors.dunkelbraun,
            child: TabBar(
              controller: _tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [Tab(text: "Direkt"), Tab(text: "Gruppen")],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ChatThread>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final threads = snap.data ?? const <ChatThread>[];
                final dms = threads.where((t) => !t.isGroup).toList();
                final gps = threads.where((t) => t.isGroup).toList();

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _ThreadList(
                        threads: dms,
                        onOpen: (t) => _openConversation(t.id),
                      ),
                      _ThreadList(
                        threads: gps,
                        onOpen: (t) => _openConversation(t.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openConversation(String chatId) async {
    final t = await getThread(chatId);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationPage(chatId: chatId, title: t.title),
      ),
    );
    _reload();
  }
}

class _ThreadList extends StatelessWidget {
  final List<ChatThread> threads;
  final void Function(ChatThread) onOpen;

  const _ThreadList({required this.threads, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return const Center(child: Text("Keine Einträge"));
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: threads.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final t = threads[i];
        final subtitle = t.lastMessage ?? "—";
        return ListTile(
          title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle:
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(_timeLabel(t.updatedAt)),
          onTap: () => onOpen(t),
        );
      },
    );
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    return "${dt.day}.${dt.month}.${dt.year}";
  }
}
