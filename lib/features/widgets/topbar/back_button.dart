import 'package:flutter/material.dart';

class NoteKeyBackButton extends StatelessWidget {
  final Color color;

  const NoteKeyBackButton({
    super.key,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: color),
      onPressed: () => Navigator.of(context).maybePop(),
      tooltip: 'Zurück',
    );
  }
}
