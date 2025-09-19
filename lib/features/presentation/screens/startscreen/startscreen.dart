import 'package:flutter/material.dart';
import 'package:notekey_app/features/themes/colors.dart';
import 'package:notekey_app/features/widgets/auth/launch_url.dart';
import '../../../widgets/startscreen_widgets/animation_logo.dart';
import '../../../widgets/startscreen_widgets/signin_button.dart';
import '../../../widgets/startscreen_widgets/headline_text.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AnimatedLogo(),
              const SizedBox(height: 32),
              const HeadlineText(),
              const SizedBox(height: 48),
              const SignupButton(),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: openNoteKeyWebsite,
                child: const Text(
                  "NOTEkey.de",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: AppColors.dunkelbraun,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
