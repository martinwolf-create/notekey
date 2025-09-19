import 'package:flutter/material.dart';

class AuthTitle extends StatelessWidget {
  final String text;
  final Color color;
  const AuthTitle({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
