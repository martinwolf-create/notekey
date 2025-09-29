import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signOut() async => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendEmailVerification() async {
    final u = _auth.currentUser;
    if (u != null && !u.emailVerified) {
      await u.sendEmailVerification();
    }
  }

  @override
  Future<bool> reloadAndIsVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<User?> signUpWithProfile({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required String address,
    required String city,
    required String country,
    required String phone,
    File? photoFile,
    int? age,
  }) async {
    //  Auth
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(username);

    // optional: Foto
    String profileImageUrl = '';
    if (photoFile != null && await photoFile.exists()) {
      final ref = _storage.ref().child('users/${user.uid}/profile.jpg');
      await ref.putFile(photoFile);
      profileImageUrl = await ref.getDownloadURL();
    }

    // Firestore: users/{uid}
    final now = FieldValue.serverTimestamp();
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email.trim(),
      'username': username.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'country': country.trim(),
      'phone': phone.trim(),
      'profileImageUrl': profileImageUrl,
      'age': age, // wird angezeigt, wenn vorhanden
      'emailVerified': user.emailVerified,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    // optional:
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory(p.join(docsDir.path, 'profiles'));
      if (!await profileDir.exists()) await profileDir.create(recursive: true);

      String? localPhotoPath;
      if (photoFile != null && await photoFile.exists()) {
        final photosDir = Directory(p.join(profileDir.path, 'photos'));
        if (!await photosDir.exists()) await photosDir.create(recursive: true);
        final dst = File(p.join(photosDir.path, '${user.uid}.jpg'));
        await photoFile.copy(dst.path);
        localPhotoPath = dst.path;
      }

      final profileJson = {
        'uid': user.uid,
        'email': email.trim(),
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'username': username.trim(),
        'address': address.trim(),
        'city': city.trim(),
        'country': country.trim(),
        'phone': phone.trim(),
        'localPhotoPath': localPhotoPath,
        'profileImageUrl': profileImageUrl,
        'age': age,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final profileFile = File(p.join(profileDir.path, '${user.uid}.json'));
      await profileFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(profileJson),
      );
    } catch (_) {}

    // 5) Verifizierungs-Mail (falls noch nicht versendet)
    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (_) {}

    return user;
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamMyUserDoc() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _db.collection('users').doc(uid).snapshots();
  }
}
