import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../data/suchfind_model.dart';
import '../data/suchfind_repository.dart';

class SuchfindProvider extends ChangeNotifier {
  final SuchfindRepository _repo = SuchfindRepository();

  List<Suchfind> _items = [];
  List<Suchfind> get items => _items;

  bool loading = true;
  bool saving = false;
  String? error;

  StreamSubscription<List<Suchfind>>? _sub;

  // Start: WATCH mit Bereich
  void start({required MarketKind kind}) {
    loading = true;
    error = null;
    notifyListeners();

    _sub?.cancel();
    _sub = _repo.watch(kind: kind).listen(
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

  Future<String> add(Suchfind s, {required MarketKind kind}) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      final id = await _repo.add(s, kind: kind);
      saving = false;
      notifyListeners();
      return id;
    } catch (e) {
      error = e.toString();
      saving = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> update(Suchfind s) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _repo.update(s);
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

  Future<String> uploadImage(File file, {required MarketKind kind}) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      final url = await _repo.uploadImage(file, kind: kind);
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
