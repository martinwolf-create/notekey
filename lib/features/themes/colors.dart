import 'package:flutter/material.dart';

/// Zentrale Farbpalette für NOTEkey.
/// Wird in allen Screens als `AppColors.xyz` verwendet.
class AppColors {
  // Basisfarben (laut deiner Palette)
  static const Color hellbeige = Color(0xFFFFF9F3);

  static const Color rosebeige = Color(0xFFF0E7DE);
  static const Color goldbraun =
      Color(0xFFA97C50); // falls du AA7C50 nutzt, hier anpassen
  static const Color dunkelbraun = Color(0xFF3F2B14);
  static const Color giftgruen = Color(0xFF4AD480);

  // Komfort-Gradienten für Karten/Buttons
  static const LinearGradient beigeGradient = LinearGradient(
    colors: [rosebeige, hellbeige],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkToDark = LinearGradient(
    colors: [dunkelbraun, dunkelbraun],
  );
}
