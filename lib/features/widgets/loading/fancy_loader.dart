import 'package:flutter/material.dart';

class FancyLoader extends StatelessWidget {
  final String text;
  const FancyLoader({super.key, this.text = 'Lädt…'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
