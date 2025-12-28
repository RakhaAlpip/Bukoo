import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_page.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/book_model.dart';
import '../../providers/favorite_provider.dart';

class DetailPage extends ConsumerWidget {
  final Book book;
  const DetailPage({super.key, required this.book});

  Future<void> _openBuyLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Gagal membuka link pembelian");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: primaryBlue,
            actions: [
              StreamBuilder<bool>(
                stream: ref.read(favoriteProvider).isFavoriteStream(book.id),
                builder: (context, snapshot) {
                  final isFav = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(favoriteProvider).toggleFavorite(
                        book.id,
                        book.title,
                        book.coverUrl,
                      );
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: book.id,
                child: Image.network(
                  book.coverUrl, 
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.book, size: 100, color: Colors.white),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      book.genre.toUpperCase(),
                      style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    book.title, 
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Penulis: ${book.author}", 
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tahun Terbit: ${book.year}", 
                    style: TextStyle(fontSize: 14, color: Colors.grey[500])
                  ),
                  const Divider(height: 40),
                  const Text(
                    "Sinopsis", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.synopsis, 
                    style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _openBuyLink("https://www.gramedia.com"),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("BELI", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Get.to(() => OrderPage(book: book)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("SEWA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}