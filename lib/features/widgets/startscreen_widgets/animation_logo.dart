import 'package:flutter/material.dart';
import 'animation_controllers.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    AnimationControllers.init(this);
  }

  @override
  void dispose() {
    AnimationControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AnimationControllers.startRotation(),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          AnimationControllers.scaleController,
          AnimationControllers.rotationController,
        ]),
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(AnimationControllers.rotationAnimation.value),
            child: Transform.scale(
              scale: AnimationControllers.scaleAnimation.value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.4),
                offset: const Offset(0, 12),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Image.asset(
            "assets/notekey_logo.png",
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
