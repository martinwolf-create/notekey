import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notekey_app/features/routes/app_routes.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;
  String? _msg;

  Future<void> _sendVerification() async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    try {
      final u = FirebaseAuth.instance.currentUser;
      if (u != null && !u.emailVerified) {
        await u.sendEmailVerification();
        _msg = 'Bestätigungs-Mail wurde gesendet.';
      } else {
        _msg = 'E-Mail ist bereits verifiziert.';
      }
    } catch (e) {
      _msg = 'Fehler: $e';
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _checkVerified() async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    await FirebaseAuth.instance.currentUser?.reload();
    final ok = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    setState(() {
      _busy = false;
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    } else {
      setState(() {
        _msg = 'Noch nicht verifiziert. Bitte Postfach prüfen.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('E-Mail bestätigen')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Wir haben eine E-Mail an $email gesendet.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _busy ? null : _sendVerification,
            child: Text(_busy ? 'Sende…' : 'Bestätigungs-Mail erneut senden'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _checkVerified,
            child: Text(_busy ? 'Prüfe…' : 'Ich habe bestätigt'),
          ),
          const Spacer(),
          if (_msg != null) Text(_msg!, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
