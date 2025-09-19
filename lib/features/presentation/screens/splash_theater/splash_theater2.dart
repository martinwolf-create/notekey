import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notekey_app/features/presentation/screens/homescreen/home_screen.dart';
import 'package:notekey_app/features/presentation/screens/startscreen/startscreen.dart';
import 'package:notekey_app/features/themes/colors.dart';

class SplashTheater2Screen extends StatefulWidget {
  const SplashTheater2Screen({super.key});

  @override
  State<SplashTheater2Screen> createState() => _SplashTheater2ScreenState();
}

class _SplashTheater2ScreenState extends State<SplashTheater2Screen>
    with TickerProviderStateMixin {
  late AnimationController _controllerA;
  late AnimationController _controllerB;
  late Animation<Offset> _animationA;
  late Animation<Offset> _animationB;

  final int lineCount = 34;

  @override
  void initState() {
    super.initState();

    _controllerA = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _controllerB = AnimationController(
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

    _animationB = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(2.0, 0),
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
          end: const Offset(2.0, 0),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controllerB);

    _controllerA.forward();
    _controllerB.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => HomeScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    super.dispose();
  }

  Widget buildTheaterLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SlideTransition(
          position: _animationA,
          child: Text(
            'NOTEkey',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.hellbeige,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SlideTransition(
          position: _animationB,
          child: Text(
            'the Music community',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.hellbeige,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dunkelbraun,
      body: Center(
        child: ListView.builder(
          itemCount: lineCount,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: buildTheaterLine(),
            );
          },
        ),
      ),
    );
  }
}
