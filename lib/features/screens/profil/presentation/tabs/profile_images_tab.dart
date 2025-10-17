import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notekey_app/features/themes/colors.dart';

class ProfileImagesTab extends StatefulWidget {
  const ProfileImagesTab({
    super.key,
    required this.ownerId,
    this.pageSize = 24,
  });

  final String ownerId;
  final int pageSize;

  @override
  State<ProfileImagesTab> createState() => _ProfileImagesTabState();
}

class _ProfileImagesTabState extends State<ProfileImagesTab> {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _scroll = ScrollController();
  final _picker = ImagePicker();

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs = [];
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastDoc;

  bool _loading = false;
  bool _hasMore = true;
  bool _initialLoaded = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loading) return;
    if (_scroll.position.extentAfter < 500) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _docs.clear();
      _lastDoc = null;
      _hasMore = true;
      _initialLoaded = false;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    Query<Map<String, dynamic>> q = _db
        .collection('media')
        .where('ownerId', isEqualTo: widget.ownerId)
        .where('type', isEqualTo: 'image')
        .orderBy('createdAt', descending: true)
        .limit(widget.pageSize);

    if (_lastDoc != null) {
      q = (q as Query<Map<String, dynamic>>).startAfterDocument(_lastDoc!);
    }

    try {
      final snap = await q.get();
      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        _docs.addAll(snap.docs);
      }
      if (snap.docs.length < widget.pageSize) {
        _hasMore = false;
      }
    } catch (_) {
      // optional: Fehler-UI
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _initialLoaded = true;
        });
      }
    }
  }

  Future<void> _pickAndUpload() async {
    final me = _auth.currentUser;
    if (me == null) return;

    final x =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (x == null) return;

    setState(() => _uploading = true);
    try {
      final file = File(x.path);
      // neues Media-Dokument anlegen (ID generieren)
      final mediaRef = _db.collection('media').doc();
      final mediaId = mediaRef.id;

      // Upload -> Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${me.uid}/media/$mediaId/original.jpg');
      await storageRef.putFile(
          file, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await storageRef.getDownloadURL();

      // Firestore schreiben
      await mediaRef.set({
        'ownerId': me.uid,
        'type': 'image',
        'originalUrl': downloadUrl,
        // Für v1 verwenden wir originalUrl auch als thumbUrl (spart Abhängigkeiten).
        // Später können wir einen echten Thumb generieren.
        'thumbUrl': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Liste auffrischen (neuestes Bild oben)
      await _refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bild hochgeladen.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteAt(int index) async {
    final me = _auth.currentUser;
    if (me == null) return;
    if (index < 0 || index >= _docs.length) return;

    final doc = _docs[index];
    final data = doc.data();
    final ownerId = data['ownerId'] as String? ?? '';
    if (ownerId != me.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nur der Besitzer kann löschen.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bild löschen?'),
        content: const Text('Dieses Bild wird endgültig entfernt. Fortfahren?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Löschen')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      // Storage: versuchen, die Datei zu löschen (optional; URL -> Ref aus Pfad rekonstruieren)
      // Wir kennen den Pfad aus unserer Struktur:
      final mediaId = doc.id;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${ownerId}/media/$mediaId/original.jpg');
      await storageRef.delete().catchError((_) {});

      // Firestore-Dokument löschen
      await doc.reference.delete();

      setState(() {
        _docs.removeAt(index);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bild gelöscht.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Löschen fehlgeschlagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width >= 900
        ? 5
        : width >= 700
            ? 4
            : 3;

    final body = (_initialLoaded && _docs.isEmpty)
        ? _emptyState()
        : GridView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: _docs.length + (_loading ? crossCount : 0),
            itemBuilder: (context, index) {
              if (index >= _docs.length) {
                return _skeleton();
              }
              final data = _docs[index].data();
              final thumb = (data['thumbUrl'] ?? '') as String;
              final original = (data['originalUrl'] ?? '') as String;
              final url = thumb.isNotEmpty ? thumb : original;

              return GestureDetector(
                onLongPress: () => _deleteAt(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _skeleton();
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.rosebeige,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              );
            },
          );

    return Stack(
      children: [
        RefreshIndicator(onRefresh: _refresh, child: body),
        // Floating Upload Button (rechts unten)
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: AppColors.goldbraun,
            onPressed: _uploading ? null : _pickAndUpload,
            child: _uploading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add_a_photo, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Icon(Icons.photo_library_outlined,
                  size: 48, color: AppColors.dunkelbraun.withOpacity(.5)),
              const SizedBox(height: 8),
              Text(
                'Noch keine Bilder',
                style: TextStyle(
                    color: AppColors.dunkelbraun.withOpacity(.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Tippe unten rechts auf das Kamera-Icon zum Hochladen.',
                style: TextStyle(color: AppColors.dunkelbraun.withOpacity(.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _skeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.rosebeige,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
