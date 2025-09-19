import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/topbar/basic_topbar.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: BasicTopBar(
          title: "Profil",
          showBack: true, // ← BackButton aktiv
          showMenu: false,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Profilbild (anklickbar)
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profilbild anklickbar")),
                );
              },
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.dunkelbraun,
                backgroundImage: const AssetImage("assets/images/user1.png"),
              ),
            ),

            const SizedBox(height: 20),

            // Name
            const Text(
              "Max Mustermann",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.dunkelbraun,
              ),
            ),

            const SizedBox(height: 10),

            // Profilbeschreibung
            const Text(
              "Musikliebhaber 🎶 | Anfänger im Notenlesen",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.dunkelbraun,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
