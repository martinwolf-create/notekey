import 'package:flutter/material.dart';

class HeadlineText extends StatelessWidget {
  const HeadlineText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "A MUSIC COMMUNITY",
      style: TextStyle(
        fontSize: 16,
        color: Color.fromRGBO(48, 36, 27, 1),
        letterSpacing: 1.2,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
