import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

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

  /// Lädt ein Bild hoch und liefert die **Download-URL** zurück.
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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
