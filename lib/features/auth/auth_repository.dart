import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);

  Future<void> sendEmailVerification();
  Future<bool> reloadAndIsVerified();

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
  });
}
