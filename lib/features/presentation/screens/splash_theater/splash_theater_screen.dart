import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/routes/app_routes.dart';

import 'package:notekey_app/features/presentation/screens/homescreen/home_screen.dart';
import 'package:notekey_app/features/themes/theme_creative.dart';
import 'package:notekey_app/features/themes/colors_creative.dart';

class SplashTheaterScreen extends StatefulWidget {
  const SplashTheaterScreen({super.key});

  @override
  State<SplashTheaterScreen> createState() => _SplashTheaterScreenState();
}

class _SplashTheaterScreenState extends State<SplashTheaterScreen>
    with TickerProviderStateMixin {
  late AnimationController _controllerA;
  late Animation<Offset> _animationA;

  late AnimationController _controllerB;
  late Animation<Offset> _animationB;

  @override
  void initState() {
    super.initState();
    // Animation A
    _controllerA = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animationA = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(-2.0, 0),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0, 0)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(-2.0, 0),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controllerA);
    // Animation B
    _controllerB = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animationB = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(2, 0),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0, 0)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(2, 0),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controllerB);

    _controllerA.forward();
    _controllerB.forward();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.home); // 👈 z.B. Home
      // oder: AppRoutes.start, AppRoutes.profil, AppRoutes.settings
    });
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsCreative.nearBlack,
      body: Stack(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SlideTransition(
                  position: _animationA,
                  child: Text(
                    "NOTEkey",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColorsCreative.magenta,
                    ),
                  ),
                ),
                SlideTransition(
                  position: _animationB,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(
                      "the Music community",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppColorsCreative.violet,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
