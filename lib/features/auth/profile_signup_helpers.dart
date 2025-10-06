// lib/features/auth/profile_signup_helpers.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSignup {
  /// Erstellt den User in Auth, lädt optional ein Profilbild hoch
  /// und legt das Profil-Dokument in Firestore an.
  static Future<void> createAccountWithOptionalAvatar({
    required Map<String, dynamic> form,
    File? avatarFile,
  }) async {
    //  Auth-User anlegen
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: form['email'] as String,
      password: form['password'] as String,
    );
    final uid = cred.user!.uid;

    //  Optional: Bild hochladen -> URL holen (erst NACH Upload!)
    String? photoUrl;
    if (avatarFile != null) {
      final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');
      final snap = await ref.putFile(
        avatarFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      if (snap.state == TaskState.success) {
        photoUrl = await ref.getDownloadURL();
        await cred.user!.updatePhotoURL(photoUrl);
      }
    }

    //  Profil-Dokument (passt zu deinen Firestore-Regeln)
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': form['email'],
      'username': form['username'],
      'firstName': form['firstName'],
      'lastName': form['lastName'],
      'address': form['address'],
      'city': form['city'],
      'country': form['country'],
      'phone': form['phone'],
      'age': form['age'],
      'emailVerified': FirebaseAuth.instance.currentUser!.emailVerified,
      'profileImageUrl': photoUrl, // darf null sein
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'roles': {'admin': false, 'moderator': false},
    });
  }
}
