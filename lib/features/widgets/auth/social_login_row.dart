import 'package:flutter/material.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _Icon(path: "assets/icons/google.png"),
        SizedBox(width: 16),
        _Icon(path: "assets/icons/apple.png"),
      ],
    );
  }
}

class _Icon extends StatelessWidget {
  final String path;
  const _Icon({required this.path});

  @override
  Widget build(BuildContext context) {
    return Image.asset(path, height: 24);
  }
}
