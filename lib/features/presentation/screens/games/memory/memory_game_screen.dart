import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekey_app/features/themes/colors.dart'; // AppColors
import 'package:notekey_app/features/presentation/screens/games/memory/widgets/memory_card.dart';

class MemoryGameScreen extends StatefulWidget {
  final bool vsComputer;
  final String player1Name;

  const MemoryGameScreen({
    super.key,
    required this.vsComputer,
    required this.player1Name,
  });

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _Tile {
  final String symbol;
  bool open = false;
  bool matched = false;
  _Tile(this.symbol);
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final _rng = Random();
  late List<_Tile> deck;

  int moves = 0;
  int score = 0;
  int? firstIndex;
  bool lock = false;
  bool player1Turn = true;

  // Musik-/Noten-Symbole
  final List<String> _symbols = const ["♩", "♪", "♫", "♬", "♭", "♮", "♯", "𝄞"];

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final base = List<String>.from(_symbols)..shuffle(_rng);
    final pick = base.take(8).toList(); // 4x4 = 8 Paare
    final list = [...pick, ...pick]..shuffle(_rng);
    deck = list.map((e) => _Tile(e)).toList();

    moves = 0;
    score = 0;
    firstIndex = null;
    lock = false;
    player1Turn = true;
    setState(() {});
  }

  Future<void> _tapCard(int i) async {
    if (lock) return;
    final t = deck[i];
    if (t.open || t.matched) return;

    HapticFeedback.lightImpact();
    setState(() => t.open = true);

    if (firstIndex == null) {
      firstIndex = i;
      return;
    }

    lock = true;
    final prev = deck[firstIndex!];
    moves += 1;

    if (prev.symbol == t.symbol) {
      // Match
      await Future.delayed(const Duration(milliseconds: 260));
      setState(() {
        prev.matched = true;
        t.matched = true;
        score += 120;
      });
      HapticFeedback.mediumImpact();
      lock = false;
      firstIndex = null;

      if (deck.every((e) => e.matched)) {
        await Future.delayed(const Duration(milliseconds: 320));
        if (!mounted) return;
        _showWinDialog();
      }
    } else {
      // Miss
      await Future.delayed(const Duration(milliseconds: 560));
      setState(() {
        prev.open = false;
        t.open = false;
        score = (score - 10).clamp(0, 999999);
        player1Turn = !player1Turn;
      });
      HapticFeedback.selectionClick();
      lock = false;
      firstIndex = null;

      // sehr simpler Computerzug
      if (widget.vsComputer && !player1Turn) {
        await Future.delayed(const Duration(milliseconds: 380));
        await _computerMove();
      }
    }
  }

  Future<void> _computerMove() async {
    if (!mounted || lock) return;
    final closed = <int>[];
    for (var i = 0; i < deck.length; i++) {
      if (!deck[i].open && !deck[i].matched) closed.add(i);
    }
    if (closed.length < 2) return;
    closed.shuffle(_rng);
    await _tapCard(closed[0]);
    await Future.delayed(const Duration(milliseconds: 260));
    await _tapCard(closed[1]);
  }

  void _showWinDialog() {
    final c = AppColors;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.hellbeige,
        title: Text("🎉 Geschafft!",
            style: TextStyle(color: AppColors.dunkelbraun)),
        content: Text("Züge: $moves\nScore: $score",
            style: TextStyle(
                color: AppColors.dunkelbraun.withOpacity(.85), fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newGame();
            },
            child:
                Text("Nochmal", style: TextStyle(color: AppColors.goldbraun)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                Text("Schließen", style: TextStyle(color: AppColors.goldbraun)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors;

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        backgroundColor: AppColors.dunkelbraun, // Appbar dunkelbraun
        centerTitle: true,
        iconTheme: const IconThemeData(
          
          color: AppColors.hellbeige, // rechts oben Pfeil
        ),
        title: const Text(
          "NOTEkey Memory",
          style: TextStyle(
            color: AppColors.hellbeige, // Titel hellbeige
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Neu mischen",
            onPressed: _newGame,
            color: AppColors.hellbeige, // appbar links: Icon(Icons.arrow_back)
            icon:
                const Icon(Icons.refresh_rounded), // appbar links: Icon(Icons.arrow_back)
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ScoreBar(
              player1: widget.player1Name,
              player2: widget.vsComputer ? "Computer" : "Spieler 2",
              player1Turn: player1Turn,
              moves: moves,
              score: score,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: deck.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final t = deck[i];
                  return MemoryCard(
                    revealed: t.open || t.matched,
                    matched: t.matched,
                    onTap: () => _tapCard(i),
                    front: Center(
                      child: Text(
                        t.symbol,
                        style: TextStyle(
                          color: AppColors.dunkelbraun,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String player1;
  final String player2;
  final bool player1Turn;
  final int moves;
  final int score;

  const _ScoreBar({
    required this.player1,
    required this.player2,
    required this.player1Turn,
    required this.moves,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.rosebeige, AppColors.hellbeige],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.goldbraun.withOpacity(.35), width: 1.1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.person, color: AppColors.dunkelbraun, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              player1Turn ? "$player1 • am Zug" : player1,
              style: TextStyle(
                  color: AppColors.dunkelbraun, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.swap_horiz_rounded,
              size: 20, color: AppColors.dunkelbraun.withOpacity(.65)),
          const SizedBox(width: 8),
          Icon(Icons.account_circle, color: AppColors.dunkelbraun, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              player1Turn ? player2 : "$player2 • am Zug",
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: AppColors.dunkelbraun, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          const _Dot(),
          const SizedBox(width: 8),
          Text("Züge: $moves",
              style: TextStyle(
                  color: AppColors.dunkelbraun.withOpacity(.85),
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          const _Dot(),
          const SizedBox(width: 8),
          Text("Score: $score",
              style: TextStyle(
                  color: AppColors.dunkelbraun.withOpacity(.85),
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
    );
  }
}
