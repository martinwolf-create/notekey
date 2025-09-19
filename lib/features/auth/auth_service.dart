import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user;
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());

    /// Registrierung + lokale Profilspeicherung (JSON + optional Foto)
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
      // 1) Account anlegen
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // 2) Anzeigename am Firebase-User setzen
      await cred.user?.updateDisplayName(username);

      // 3) Lokales Profil speichern
      final docsDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory(p.join(docsDir.path, 'profiles'));
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      String? localPhotoPath;
      if (photoFile != null && await photoFile.exists()) {
        final photosDir = Directory(p.join(profileDir.path, 'photos'));
        if (!await photosDir.exists()) {
          await photosDir.create(recursive: true);
        }
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

      final profileFile =
          File(p.join(profileDir.path, '${cred.user!.uid}.json'));
      await profileFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(profileJson));

      return cred.user;
    }
  }
}
