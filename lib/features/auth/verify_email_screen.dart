import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notekey_app/features/routes/app_routes.dart';
import 'package:notekey_app/features/themes/colors.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false, _checking = false;
  String? _msg;

  Future<void> _sendVerification() async {
    setState(() {
      _sending = true;
      _msg = null;
    });
    try {
      final u = FirebaseAuth.instance.currentUser;
      if (u != null && !u.emailVerified) {
        await u.sendEmailVerification();
        _msg = 'Bestätigungs-E-Mail wurde gesendet.';
      } else {
        _msg = 'E-Mail ist bereits verifiziert.';
      }
    } catch (e) {
      _msg = 'Fehler: $e';
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  Future<void> _checkVerified() async {
    setState(() {
      _checking = true;
      _msg = null;
    });
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (verified) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (_) => false);
      } else {
        _msg = 'Noch nicht verifiziert. Bitte Postfach prüfen.';
      }
    } finally {
      setState(() {
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Mail bestätigen'),
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Wir haben eine E-Mail an $email gesendet.'),
          const SizedBox(height: 8),
          const Text(
              'Klicke auf den Link in der Mail und tippe dann unten auf „Ich habe bestätigt“.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _sending ? null : _sendVerification,
            child:
                Text(_sending ? 'Sende…' : 'Bestätigungs-Mail erneut senden'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _checking ? null : _checkVerified,
            child: Text(_checking ? 'Prüfe…' : 'Ich habe bestätigt'),
          ),
          const Spacer(),
          if (_msg != null) Text(_msg!, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
