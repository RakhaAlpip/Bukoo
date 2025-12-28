import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/book_model.dart';
import '../../providers/rent_provider.dart';

class OrderPage extends ConsumerStatefulWidget {
  final Book book;
  const OrderPage({super.key, required this.book});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  int _selectedDays = 1;
  final int _pricePerDay = 5000;

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);
    final int totalPrice = _selectedDays * _pricePerDay;
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Konfirmasi Sewa", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(widget.book.coverUrl, width: 80, height: 120, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.book, size: 80)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.book.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(widget.book.author, style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text(widget.book.genre, style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 40),

            const Text("Lama Penyewaan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Durasi (Maks. 7 Hari)"),
                Row(
                  children: [
                    _counterButton(Icons.remove, () {
                      if (_selectedDays > 1) setState(() => _selectedDays--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("$_selectedDays", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    _counterButton(Icons.add, () {
                      if (_selectedDays < 7) setState(() => _selectedDays++);
                    }),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 3. Rincian Harga
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _priceRow("Harga Sewa / Hari", currencyFormat.format(_pricePerDay)),
                  const SizedBox(height: 8),
                  _priceRow("Durasi", "$_selectedDays Hari"),
                  const Divider(height: 24),
                  _priceRow("Total Pembayaran", currencyFormat.format(totalPrice), isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
      
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton(
          onPressed: () {
            ref.read(rentProvider).rentBook(
              bookId: widget.book.id,
              title: widget.book.title,
              coverUrl: widget.book.coverUrl,
              days: _selectedDays,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("KONFIRMASI SEWA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : 14, color: isTotal ? const Color(0xFF0D47A1) : Colors.black)),
      ],
    );
  }
}