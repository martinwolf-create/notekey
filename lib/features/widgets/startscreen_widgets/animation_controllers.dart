import 'dart:math';
import 'package:flutter/material.dart';

class AnimationControllers {
  static late AnimationController scaleController;
  static late Animation<double> scaleAnimation;

  static late AnimationController rotationController;
  static late Animation<double> rotationAnimation;

  static void init(TickerProvider vsync) {
    scaleController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOut,
    ));

    rotationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );

    rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(rotationController);
  }

  static void dispose() {
    scaleController.dispose();
    rotationController.dispose();
  }

  static void startRotation() {
    final random = Random();
    final direction = random.nextBool() ? 1 : -1;
    final turns = random.nextInt(3) + 1;
    final endAngle = direction * turns * 2 * pi;

    rotationAnimation = Tween<double>(
      begin: 0,
      end: endAngle,
    ).animate(CurvedAnimation(
      parent: rotationController,
      curve: Curves.easeOutCubic,
    ));

    rotationController
      ..duration = const Duration(milliseconds: 800)
      ..reset()
      ..forward();
  }
}
