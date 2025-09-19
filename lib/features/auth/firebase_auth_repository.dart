import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  FirebaseAuthRepository({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
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
    if (u != null && !u.emailVerified) await u.sendEmailVerification();
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
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await cred.user?.updateDisplayName(username);

    final docsDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory(p.join(docsDir.path, 'profiles'));
    if (!await profileDir.exists()) await profileDir.create(recursive: true);

    String? localPhotoPath;
    if (photoFile != null && await photoFile.exists()) {
      final photosDir = Directory(p.join(profileDir.path, 'photos'));
      if (!await photosDir.exists()) await photosDir.create(recursive: true);
      final dst = File(p.join(photosDir.path, '${cred.user!.uid}.jpg'));
      await photoFile.copy(dst.path);
      localPhotoPath = dst.path;
    }

    final profileJson = {
      'uid': cred.user!.uid,
      'email': email.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'username': username.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'country': country.trim(),
      'phone': phone.trim(),
      'localPhotoPath': localPhotoPath,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    final profileFile = File(p.join(profileDir.path, '${cred.user!.uid}.json'));
    await profileFile
        .writeAsString(const JsonEncoder.withIndent('  ').convert(profileJson));

    await sendEmailVerification();
    return cred.user;
  }
}
