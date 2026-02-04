import 'package:flutter_test/flutter_test.dart';

class BookValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Judul tidak boleh kosong';
    }
    return null;
  }

  static int calculateDiscount(int price, int discountPercent) {
    return price - (price * discountPercent ~/ 100);
  }
}
// -------------------------------------------------------------------------

void main() {
  group('Book Logic Test', () {
    test('Validasi judul harus error jika kosong', () {
      var result = BookValidator.validateTitle('');
      expect(result, 'Judul tidak boleh kosong');
    });

    test('Validasi judul harus null (sukses) jika ada isi', () {
      var result = BookValidator.validateTitle('Belajar Flutter');
      expect(result, null);
    });

    test('Hitung harga diskon harus benar', () {
      var finalPrice = BookValidator.calculateDiscount(100000, 20);
      expect(finalPrice, 80000);
    });
  });
}