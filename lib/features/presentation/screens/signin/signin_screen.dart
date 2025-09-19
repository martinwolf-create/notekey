import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notekey_app/features/auth/auth_repository.dart';
import 'package:notekey_app/features/routes/app_routes.dart';
import 'package:notekey_app/features/themes/colors.dart';

class SignInScreen extends StatefulWidget {
  final AuthRepository auth;
  const SignInScreen({super.key, required this.auth});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  String? _vEmail(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'E-Mail eingeben';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
        ? null
        : 'Ungültige E-Mail';
  }

  String? _vPw(String? v) => (v == null || v.isEmpty)
      ? 'Passwort eingeben'
      : (v.length < 6 ? 'Mind. 6 Zeichen' : null);

  String _map(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Ungültige E-Mail.';
      case 'user-not-found':
      case 'wrong-password':
        return 'E-Mail oder Passwort falsch.';
      case 'user-disabled':
        return 'Konto deaktiviert.';
      case 'too-many-requests':
        return 'Zu viele Versuche. Später erneut.';
      default:
        return 'Login fehlgeschlagen (${e.code}).';
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.auth
          .signInWithEmailAndPassword(_emailCtrl.text, _pwCtrl.text);
      final ok = await widget.auth.reloadAndIsVerified();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
          context, ok ? AppRoutes.home : AppRoutes.verify);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _map(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte E-Mail eingeben.')));
      return;
    }
    await widget.auth.sendPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset-E-Mail wurde gesendet.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.dunkelbraun,
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.memory, (_) => false),
        child: const Icon(Icons.visibility_off, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Sign in',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dunkelbraun)),
                  const SizedBox(height: 24),
                  TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-Mail'),
                      validator: _vEmail,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: _pwCtrl,
                      decoration: const InputDecoration(labelText: 'Passwort'),
                      validator: _vPw,
                      obscureText: true),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: _loading ? null : _reset,
                          child: const Text('Passwort vergessen?'))),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: _loading ? null : _signIn,
                      child: Text(_loading ? 'Bitte warten…' : 'Sign in')),
                  TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.signup),
                      child: const Text('Noch kein Konto? Registrieren')),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                  ]
                ]),
          ),
        ),
      ),
    );
  }
}
