import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

// NEU
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../data/veranstaltung_model.dart';
import '../data/veranstaltung_repository.dart';

class VeranstaltungProvider extends ChangeNotifier {
  final VeranstaltungRepository _repo = VeranstaltungRepository();

  List<Veranstaltung> _items = [];
  List<Veranstaltung> get items => _items;

  bool loading = true;
  bool saving = false;
  String? error;

  StreamSubscription<List<Veranstaltung>>? _sub;

  /// Startet den Stream für die Liste (z. B. im ListScreen verwenden).
  void start() {
    loading = true;
    error = null;
    notifyListeners();

    _sub?.cancel();
    _sub = _repo.watchAll().listen(
      (list) {
        _items = list;
        loading = false;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        loading = false;
        notifyListeners();
      },
    );
  }

  /// Fügt eine Veranstaltung hinzu und gibt die neu erzeugte **Doc-ID** zurück.
  Future<String> add(Veranstaltung v) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      final id = await _repo.add(v);
      saving = false;
      notifyListeners();
      return id;
    } catch (e) {
      error = e.toString();
      saving = false;
      notifyListeners();
      rethrow; // Fehler nicht verschlucken -> UI kann SnackBar zeigen
    }
  }

  Future<void> update(Veranstaltung v) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _repo.update(v);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _repo.delete(id);
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  /// Bestehende Variante: nutzt dein Repository (kann bleiben)
  Future<String> uploadImage(File file) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      final url = await _repo.uploadImage(file);
      return url;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  /// NEU: Sicherer Upload passend zu deinen Storage-Regeln
  /// Speichert unter: events/{ownerUid}/{timestamp}.{ext}
  Future<String> uploadEventImage(
    File file, {
    String? ownerUid,
    String? eventId,
  }) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      final uid = ownerUid ?? FirebaseAuth.instance.currentUser!.uid;

      final ext = _inferImageExt(file.path); // jpg/png/webp (fallback: jpg)
      final contentType = _contentTypeFromExt(ext);

      final String filename =
          (eventId ?? DateTime.now().millisecondsSinceEpoch.toString()) +
              '.$ext';

      final ref = FirebaseStorage.instance
          .ref()
          .child('events/$uid/$filename'); // <-- passt 1:1 zu deinen Regeln

      final metadata = SettableMetadata(contentType: contentType);

      await ref.putFile(file, metadata);
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  // --- Helpers für ContentType/Extension ---

  String _inferImageExt(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'png';
    if (p.endsWith('.webp')) return 'webp';
    if (p.endsWith('.jpg') || p.endsWith('.jpeg')) return 'jpg';
    // iOS/Android geben manchmal keine Endung -> als jpg speichern
    return 'jpg';
  }

  String _contentTypeFromExt(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
