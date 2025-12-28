import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

final rentProvider = Provider((ref) => RentService());

class RentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> rentBook({
    required String bookId,
    required String title,
    required String coverUrl,
    required int days,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Kamu harus login terlebih dahulu");
      return;
    }

    int total = days * 5000;
    DateTime returnDate = DateTime.now().add(Duration(days: days));

    try {
      await _firestore.collection('rentals').add({
        'userId': user.uid,
        'bookId': bookId,
        'title': title,
        'coverUrl': coverUrl,
        'days': days,
        'totalPrice': total,
        'rentDate': Timestamp.now(),
        'returnDate': Timestamp.fromDate(returnDate),
      });

      Get.back(); 
      Get.snackbar("Berhasil", "Buku $title telah disewa!");
    } catch (e) {
      Get.snackbar("Error", "Gagal menyewa: $e");
    }
  }
}