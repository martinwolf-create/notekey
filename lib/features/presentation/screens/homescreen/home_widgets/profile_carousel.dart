import 'package:flutter/material.dart';

class ProfileCarousel extends StatelessWidget {
  final List<String> profileImages;
  const ProfileCarousel({super.key, required this.profileImages});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: profileImages.length * 100, // Endlos-Effekt
        itemBuilder: (context, index) {
          final image = profileImages[index % profileImages.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 90,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
