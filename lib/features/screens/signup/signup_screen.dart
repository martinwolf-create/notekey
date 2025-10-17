import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notekey_app/features/auth/auth_repository.dart';
import 'package:notekey_app/features/routes/app_routes.dart';
import 'package:notekey_app/features/themes/colors.dart';

class SignUpScreen extends StatefulWidget {
  final AuthRepository auth;
  const SignUpScreen({super.key, required this.auth});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();

  final _picker = ImagePicker();
  File? _photo;

  bool _loading = false;
  String? _error;

  final _usernameRe = RegExp(r'^[a-zA-Z0-9_\.]{3,20}$');
  String? _req(String? v, String l) =>
      (v ?? '').trim().isEmpty ? '$l eingeben' : null;
  String? _vUsername(String? v) =>
      (v == null || !_usernameRe.hasMatch(v.trim()))
          ? '3–20 Zeichen (a–Z, 0–9, _ .)'
          : null;
  String? _vEmail(String? v) =>
      (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))
          ? 'Ungültige E-Mail'
          : null;
  String? _vPhone(String? v) =>
      (v == null || !RegExp(r'^\+?[0-9 ]{6,20}$').hasMatch(v.trim()))
          ? 'Ungültige Telefonnummer'
          : null;
  String? _vPw(String? v) {
    if (v == null) return 'Passwort eingeben';
    final ok = v.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(v) &&
        RegExp(r'[a-z]').hasMatch(v) &&
        RegExp(r'\d').hasMatch(v) &&
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v);
    return ok ? null : 'Min. 8, Groß/Klein, Zahl, Sonderzeichen';
  }

  String? _vPw2(String? v) => v == _pw.text ? null : 'Passwörter stimmen nicht';

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _address.dispose();
    _city.dispose();
    _country.dispose();
    _phone.dispose();
    _email.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final x =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _photo = File(x.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.auth.signUpWithProfile(
        email: _email.text.trim(),
        password: _pw.text,
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        username: _username.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        country: _country.text.trim(),
        phone: _phone.text.trim(),
        photoFile: _photo,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.verify, (_) => false);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrieren'),
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.rosebeige,
                  backgroundImage: _photo != null ? FileImage(_photo!) : null,
                  child: _photo == null
                      ? const Icon(Icons.add_a_photo,
                          color: AppColors.dunkelbraun)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'Vorname'),
                    validator: (v) => _req(v, 'Vorname')),
                TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Nachname'),
                    validator: (v) => _req(v, 'Nachname')),
                const SizedBox(height: 8),
                TextFormField(
                    controller: _username,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: _vUsername),
                const SizedBox(height: 8),
                TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(
                        labelText: 'Adresse (Straße, Nr.)'),
                    validator: (v) => _req(v, 'Adresse')),
                TextFormField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'Stadt'),
                    validator: (v) => _req(v, 'Stadt')),
                TextFormField(
                    controller: _country,
                    decoration: const InputDecoration(labelText: 'Land'),
                    validator: (v) => _req(v, 'Land')),
                TextFormField(
                    controller: _phone,
                    decoration:
                        const InputDecoration(labelText: 'Telefonnummer'),
                    validator: _vPhone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                    validator: _vEmail,
                    keyboardType: TextInputType.emailAddress),
                TextFormField(
                    controller: _pw,
                    decoration: const InputDecoration(labelText: 'Passwort'),
                    validator: _vPw,
                    obscureText: true),
                TextFormField(
                    controller: _pw2,
                    decoration: const InputDecoration(
                        labelText: 'Passwort (Wiederholen)'),
                    validator: _vPw2,
                    obscureText: true),
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child:
                        Text(_loading ? 'Wird erstellt…' : 'Konto erstellen')),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.signin),
                  child: const Text('Zurück zum Login'),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
