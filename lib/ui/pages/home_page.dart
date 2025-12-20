import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Jangan lupa add intl di pubspec
import '../../providers/book_provider.dart';
import '../../data/models/book_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil data buku (AsyncValue)
    final booksAsync = ref.watch(booksProvider);
    // Ambil state filter saat ini
    final filterState = ref.watch(filterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Katalog Buku")),
      body: Column(
        children: [
          // --- FILTER SECTION ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // 1. Search Bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari judul buku...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onSubmitted: (value) {
                    // Update keyword di provider
                    ref.read(filterProvider.notifier).update(
                          (state) => state.copyWith(keyword: value),
                        );
                  },
                ),
                const SizedBox(height: 10),
                // 2. Sort Dropdown
                DropdownButtonFormField<String>(
                  value: filterState.sort,
                  decoration: const InputDecoration(
                    labelText: 'Urutkan',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
                    DropdownMenuItem(value: 'oldest', child: Text('Terlama')),
                    DropdownMenuItem(value: 'titleAZ', child: Text('Judul A-Z')),
                    DropdownMenuItem(value: 'titleZA', child: Text('Judul Z-A')),
                    DropdownMenuItem(value: 'priceLowHigh', child: Text('Harga Termurah')),
                    DropdownMenuItem(value: 'priceHighLow', child: Text('Harga Termahal')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(filterProvider.notifier).update(
                            (state) => state.copyWith(sort: value),
                          );
                    }
                  },
                ),
              ],
            ),
          ),

          // --- LIST SECTION ---
          Expanded(
            child: booksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (books) {
                if (books.isEmpty) {
                  return const Center(child: Text("Tidak ada buku ditemukan."));
                }
                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return BookCard(book: book);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Terpisah untuk Card Buku
class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: SizedBox(
          width: 50,
          child: Image.network(
            book.coverUrl,
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => const Icon(Icons.book),
          ),
        ),
        title: Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.author),
            Text(
              currencyFormatter.format(book.price),
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        onTap: () {
          // Nanti arahkan ke Detail Page di sini
          // Navigator.push(...);
        },
      ),
    );
  }
}