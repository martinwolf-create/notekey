import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:notekey_app/features/presentation/screens/forum/data/forum_item.dart';

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
      widget.collection == "veranstaltung" || widget.collection == "suchfind";

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
      _toast("Bildauswahl fehlgeschlagen: $e");
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Nicht eingeloggt.");

      // Firestore Rules, Email-Status sehen
      await user.reload();
      await user.getIdToken(true);

      final verified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (_needsVerifiedEmail && !verified) {
        _toast(
          "Bitte bestätige zuerst deine E-Mail-Adresse.\n"
          "Klicke im Postfach auf den Bestätigungslink und versuche es erneut.",
        );
        return;
      }

      final uid = user.uid;

      // Optional: Bild hochladen
      String? imageUrl;
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref().child(
              "${widget.collection}/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg",
            );
        final uploadTask = ref.putFile(
          _imageFile!,
          SettableMetadata(contentType: "image/jpeg"),
        );
        await uploadTask
            .whenComplete(() {})
            .timeout(const Duration(seconds: 25));
        imageUrl = await ref.getDownloadURL();
      }

      // Firestore-Daten vorbereiten
      final data = <String, dynamic>{
        if (widget.collection == "todo") "userId": uid else "uid": uid,
        if (widget.collection == "veranstaltung")
          "type": 0, // 0 = ForumItemType.event
        if (widget.collection == "suchfind")
          "type": 1, // 1 = ForumItemType.suchfind
        if (widget.collection == "todo") "type": 2, // 2 = ForumItemType.todo

        "title": _titleCtrl.text.trim(),
        "info": _infoCtrl.text.trim(),
        if (imageUrl != null) "imageUrl": imageUrl,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection(widget.collection)
          .add(data)
          .timeout(const Duration(seconds: 20));

      _toast("Gespeichert ✔︎");
      if (!mounted) return;
      Navigator.of(context).pop();
    } on TimeoutException {
      _toast(
          "Zeitüberschreitung – bitte Internet prüfen und erneut versuchen.");
    } on FirebaseException catch (e) {
      _toast("Firebase-Fehler: ${e.code} — ${e.message ?? ''}");
    } catch (e) {
      _toast("Fehler: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.collection) {
      "veranstaltung" => "Veranstaltung erstellen",
      "suchfind" => "Such & Find – Eintrag",
      "todo" => "To-Do hinzufügen",
      _ => "Eintrag",
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
                      ? const Text("Bild auswählen")
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
                decoration: const InputDecoration(labelText: "Titel"),
                maxLength: 120,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Bitte Titel eingeben"
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _infoCtrl,
                decoration: const InputDecoration(labelText: "Info"),
                maxLines: 6,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? "Bitte Info eingeben"
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
                      : const Text("Speichern"),
                ),
              ),
              if (_needsVerifiedEmail)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    "Hinweis: Für ${widget.collection} ist eine verifizierte E-Mail erforderlich.",
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
