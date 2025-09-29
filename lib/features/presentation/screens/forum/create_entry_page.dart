// presentation/screens/forum/create_entry_page.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// Nutzung: veranstaltung/suchfind/todo
// - veranstaltung/suchfind erfordern verifizierte E-Mail
class CreateEntryPage extends StatefulWidget {
  final String collection;

  const CreateEntryPage({super.key, required this.collection});

  @override
  State<CreateEntryPage> createState() => _CreateEntryPageState();
}

class _CreateEntryPageState extends State<CreateEntryPage> {
  final _titleCtrl = TextEditingController();
  final _infoCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _infoCtrl.dispose();
    super.dispose();
  }

  bool get _needsVerifiedEmail =>
      widget.collection == 'veranstaltung' || widget.collection == 'suchfind';

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImage() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) return;
      setState(() => _imageFile = File(x.path));
    } catch (e) {
      _toast('Bildauswahl fehlgeschlagen: $e');
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Nicht eingeloggt.');

      // Email-Verifizierung aktualisieren & prüfen
      await user.reload();
      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (_needsVerifiedEmail && !verified) {
        setState(() => _isLoading = false);
        _toast(
          'Bitte bestätige zuerst deine E-Mail-Adresse.\n'
          'Öffne dein Postfach und tippe danach erneut auf „Speichern“.',
        );
        return;
      }

      final uid = user.uid;

      // Optional: Bild hochladen (mit Timeout)
      String? imageUrl;
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref().child(
            '${widget.collection}/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = ref.putFile(
          _imageFile!,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        // auf Abschluss warten + Timeout
        await uploadTask
            .whenComplete(() {})
            .timeout(const Duration(seconds: 25));

        imageUrl = await ref.getDownloadURL();
      }

      // Firestore-Daten gemäß Regeln:
      // - 'todo' erwartet 'userId'
      // - veranstaltung/suchfind erwarten 'uid'
      final data = <String, dynamic>{
        if (widget.collection == 'todo') 'userId': uid else 'uid': uid,
        'title': _titleCtrl.text.trim(),
        'info': _infoCtrl.text.trim(),
        if (imageUrl != null) 'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection(widget.collection)
          .add(data)
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;
      setState(() => _isLoading = false);
      _toast('Gespeichert ✔︎');
      Navigator.of(context).pop();
    } on TimeoutException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _toast(e.message ?? 'Zeitüberschreitung');
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _toast('Firebase-Fehler: ${e.code}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _toast('Fehler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.collection) {
      'veranstaltung' => 'Veranstaltung erstellen',
      'suchfind' => 'Such & Find – Eintrag',
      'todo' => 'To-Do hinzufügen',
      _ => 'Eintrag',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.brown.shade200),
                  ),
                  child: _imageFile == null
                      ? const Text('Bild auswählen')
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Titel'),
                maxLength: 120,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Bitte Titel eingeben'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _infoCtrl,
                decoration: const InputDecoration(labelText: 'Info'),
                maxLines: 6,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Bitte Info eingeben'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Speichern'),
                ),
              ),
              if (_needsVerifiedEmail)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Hinweis: Für ${widget.collection} ist eine verifizierte E-Mail erforderlich.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
