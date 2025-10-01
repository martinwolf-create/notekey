import 'package:flutter/material.dart';

class VeranstaltungComments extends StatelessWidget {
  const VeranstaltungComments({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Kommentare",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text("Hier kommen später die Kommentare…"),
      ],
    );
  }
}
