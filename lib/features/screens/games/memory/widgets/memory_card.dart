import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notekey_app/features/themes/colors.dart'; // AppColors

/// Memory-Karte mit:
/// • 3D-Flip (Y-Achse)
/// • Press-Feedback

class MemoryCard extends StatefulWidget {
  final bool revealed;
  final bool matched;
  final Widget front; // Inhalt, wenn aufgedeckt (z. B. Symbol/Text)
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.revealed,
    required this.matched,
    required this.front,
    required this.onTap,
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard> with TickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final Animation<double> _flip;

  late final AnimationController _pressCtrl;
  late final Animation<double> _press;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flip = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic);

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _press = CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut);

    if (widget.revealed) _flipCtrl.value = 1;
  }

  @override
  void didUpdateWidget(covariant MemoryCard old) {
    super.didUpdateWidget(old);
    if (widget.revealed && _flipCtrl.status != AnimationStatus.completed) {
      _flipCtrl.forward();
    } else if (!widget.revealed &&
        _flipCtrl.status != AnimationStatus.dismissed) {
      _flipCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors;

    return Listener(
      onPointerDown: (_) => _pressCtrl.forward(),
      onPointerUp: (_) => _pressCtrl.reverse(),
      onPointerCancel: (_) => _pressCtrl.reverse(),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_flip, _press]),
          builder: (context, _) {
            final angle = _flip.value * math.pi; // 0..pi
            final isBack = angle <= math.pi / 2; // 90° Rückseite
            final tilt = _press.value * 0.06; // leichter Tilt beim Press
            final glow = widget.matched ? 22.0 : 14.0;
            final glowOpacity = widget.matched ? .28 : .16;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0018)
                ..rotateX(-tilt) // leichter Tilt nach hinten beim Press
                ..rotateY(angle),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldbraun.withOpacity(glowOpacity),
                      blurRadius: glow,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.goldbraun.withOpacity(.35),
                          width: 1.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Rückseite (Orange-Gradient)
                        Opacity(
                          opacity: isBack ? 1 : 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(255, 245, 134, 7),
                                  AppColors.dunkelbraun
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(Icons.music_note_rounded,
                                  size: 36, color: AppColors.hellbeige),
                            ),
                          ),
                        ),
                        // Vorderseite (Beige-Gradient)
                        Opacity(
                          opacity: isBack ? 0 : 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.rosebeige,
                                  AppColors.hellbeige
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: widget.front,
                          ),
                        ),
                        // sanfter Glanz beim Press
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: AnimatedOpacity(
                              opacity: _press.value * .25,
                              duration: const Duration(milliseconds: 120),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(.35),
                                      Colors.transparent
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
