import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

final authProvider = Provider((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> signUp(String email, String password, String name) async {
    if (!isPasswordValid(password)) {
      Get.snackbar(
        "Password Lemah", 
        "Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
      );
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      Get.snackbar("Sukses", "Akun $name berhasil dibuat!", 
        backgroundColor: const Color(0xFF0D47A1), colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Gagal Daftar", e.message ?? "Terjadi kesalahan");
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Selamat Datang", "Berhasil masuk ke Bukoo",
        backgroundColor: const Color(0xFF0D47A1), colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Gagal Login", "Email atau password salah.");
    }
  }

  Future<void> signOut() async => await _auth.signOut();
}