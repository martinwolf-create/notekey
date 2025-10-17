import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:notekey_app/features/themes/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _picker = ImagePicker();

  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _city = '';
  String _country = '';
  String _phone = '';
  String _bio = '';
  int? _age;
  String _photoUrl = '';
  File? _localImage;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _db.collection('users').doc(uid).get();
    if (!mounted)
      return; // Schutz, falls Screen während des Ladens geschlossen wird
    final d = doc.data() ?? {};
    setState(() {
      _username = (d['username'] ?? '').toString();
      _firstName = (d['firstName'] ?? '').toString();
      _lastName = (d['lastName'] ?? '').toString();
      _city = (d['city'] ?? '').toString();
      _country = (d['country'] ?? '').toString();
      _phone = (d['phone'] ?? '').toString();
      _bio = (d['bio'] ?? '').toString();
      _photoUrl = (d['profileImageUrl'] ?? '').toString();
      _age = (d['age'] is int) ? d['age'] as int : null;
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final x =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (x != null) setState(() => _localImage = File(x.path));
  }

  Future<String?> _uploadAvatarIfNeeded(String uid) async {
    if (_localImage == null) return _photoUrl;
    final file = _localImage!;
    final mime = lookupMimeType(file.path) ?? 'image/jpeg';
    final isPng = mime.endsWith('png');
    final ref = FirebaseStorage.instance
        .ref()
        .child('public/avatars/$uid${isPng ? '.png' : '.jpg'}');
    final metadata = SettableMetadata(contentType: mime);
    await ref.putFile(file, metadata);
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    _formKey.currentState!.save();

    final uid = _auth.currentUser!.uid;
    try {
      final newPhotoUrl = await _uploadAvatarIfNeeded(uid) ?? '';
      final data = <String, dynamic>{
        'username': _username.trim(),
        'firstName': _firstName.trim(),
        'lastName': _lastName.trim(),
        'city': _city.trim(),
        'country': _country.trim(),
        'phone': _phone.trim(),
        'bio': _bio.trim(),
        'profileImageUrl': newPhotoUrl,
        'age': _age,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      data.removeWhere((k, v) => v is String && v.trim().isEmpty);

      await _db.collection('users').doc(uid).update(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil erfolgreich aktualisiert')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speichern fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.hellbeige,
        appBar: AppBar(
          title: const Text('Profil bearbeiten'),
          backgroundColor: AppColors.dunkelbraun,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.hellbeige,
      appBar: AppBar(
        title: const Text('Profil bearbeiten'),
        backgroundColor: AppColors.dunkelbraun,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.rosebeige,
                      backgroundImage: _localImage != null
                          ? FileImage(_localImage!)
                          : (_photoUrl.isNotEmpty
                              ? NetworkImage(_photoUrl)
                              : null) as ImageProvider<Object>?,
                      child: _photoUrl.isEmpty && _localImage == null
                          ? const Icon(Icons.person,
                              size: 40, color: AppColors.dunkelbraun)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: AppColors.goldbraun,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(24),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Profilbild (öffentlich)\nTippe auf den Stift zum Ändern.',
                    style:
                        TextStyle(color: AppColors.dunkelbraun.withOpacity(.7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _field(
              label: 'Username',
              initial: _username,
              onSaved: (v) => _username = v ?? '',
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? 'Mind. 3 Zeichen' : null,
            ),
            _field(
              label: 'Vorname',
              initial: _firstName,
              onSaved: (v) => _firstName = v ?? '',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
            ),
            _field(
              label: 'Nachname',
              initial: _lastName,
              onSaved: (v) => _lastName = v ?? '',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
            ),
            _field(
                label: 'Stadt',
                initial: _city,
                onSaved: (v) => _city = v ?? ''),
            _field(
                label: 'Land',
                initial: _country,
                onSaved: (v) => _country = v ?? ''),
            _field(
                label: 'Telefon',
                initial: _phone,
                onSaved: (v) => _phone = v ?? ''),
            _field(label: 'Bio', initial: _bio, onSaved: (v) => _bio = v ?? ''),
            _numberField(
              label: 'Alter',
              initial: _age?.toString() ?? '',
              onSaved: (v) =>
                  _age = (v == null || v.isEmpty) ? null : int.tryParse(v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldbraun,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'Speichern…' : 'Speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    String? initial,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initial,
        validator: validator,
        onSaved: onSaved,
        style: const TextStyle(color: AppColors.dunkelbraun),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.dunkelbraun.withOpacity(.8)),
          filled: true,
          fillColor: AppColors.rosebeige,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.goldbraun),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.goldbraun, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _numberField({
    required String label,
    String? initial,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initial,
        keyboardType: TextInputType.number,
        onSaved: onSaved,
        style: const TextStyle(color: AppColors.dunkelbraun),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.dunkelbraun.withOpacity(.8)),
          filled: true,
          fillColor: AppColors.rosebeige,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.goldbraun),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.goldbraun, width: 2),
          ),
        ),
      ),
    );
  }
}
