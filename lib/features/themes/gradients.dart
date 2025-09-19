import 'package:flutter/material.dart';
import 'colors_creative.dart';

class AppGradients {
  static const blueToViolet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2A38), AppColorsCreative.violet],
  );

  static const violetToMagenta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColorsCreative.violet, AppColorsCreative.magenta],
  );

  static const fresh = LinearGradient(
    begin: Alignment(0.2, -1),
    end: Alignment(0.9, 1),
    colors: [
      Color(0xFF20E3E3),
      AppColorsCreative.electricGreen,
      AppColorsCreative.sunYellow
    ],
  );
  //static const darkToLight = LinearGradient(
  //begin: Alignment.topLeft,
  //end: Alignment.bottomRight,
  //colors: [AppColorsCreative.nearBlack, Color(0xFF2A3A4E)],
  //);
}
