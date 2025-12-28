import 'package:bukoo/ui/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import 'detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        ref.read(bookNotifierProvider.notifier).fetchBooks();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookNotifierProvider);
    final filter = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Bukoo", 
          style: TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle_rounded, color: Colors.orange),
            tooltip: "Pilih Buku Acak",
            onPressed: () {
              final books = bookState.books;
              if (books.isNotEmpty) {
                final randomBook = (List.from(books)..shuffle()).first; 
                Get.to(() => DetailPage(book: randomBook));
                Get.snackbar(
                  "Buku Acak Untukmu!", 
                  "Gimana kalau baca '${randomBook.title}'?",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange[800],
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(15),
                  duration: const Duration(seconds: 2),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => Get.to(() => const ProfilePage()),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => ref.read(authProvider).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(ref),
          const SizedBox(height: 16), 
          const GenreStatsWidget(), 
          const SizedBox(height: 16),
          _buildFilterAndSort(ref, filter),
          const SizedBox(height: 12),

          Expanded(
            child: isGridView 
              ? _buildBookGrid(bookState) 
              : _buildBookList(bookState), 
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid(BookState state) {
    if (state.books.isEmpty && state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.books.isEmpty) return _buildEmptyState();
    return GridView.builder(
      controller: _scrollController, 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12, 
      ),
      itemCount: state.books.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.books.length) {
          final book = state.books[index];
          return GestureDetector(
            onTap: () => Get.to(() => DetailPage(book: book)),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(book.coverUrl, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.book, color: Colors.grey))),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildBookList(BookState state) {
    if (state.books.isEmpty && state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.books.isEmpty) return _buildEmptyState();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.books.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.books.length) {
          final book = state.books[index];
          final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(book.coverUrl, width: 50, height: 70, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.book))),
              title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${book.author}\n${currencyFormat.format(book.price)}"),
              onTap: () => Get.to(() => DetailPage(book: book)),
            ),
          );
        }
        return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("Buku tidak ditemukan", style: TextStyle(color: Colors.grey)),
        ]),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
        child: TextField(
          onChanged: (val) {
            ref.read(filterProvider.notifier).update((s) => s.copyWith(keyword: val));
            ref.read(bookNotifierProvider.notifier).fetchBooks(isRefresh: true);
          },
          decoration: const InputDecoration(hintText: "Cari judul buku...", prefixIcon: Icon(Icons.search, color: Color(0xFF0D47A1)), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15)),
        ),
      ),
    );
  }

  Widget _buildFilterAndSort(WidgetRef ref, FilterState filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: filter.sort,
        decoration: const InputDecoration(labelText: "Urutkan", border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        items: const [
          DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
          DropdownMenuItem(value: 'oldest', child: Text('Terlama')),
          DropdownMenuItem(value: 'titleAZ', child: Text('Judul A-Z')),
          DropdownMenuItem(value: 'titleZA', child: Text('Judul Z-A')),
          DropdownMenuItem(value: 'priceLowHigh', child: Text('Termurah')),
          DropdownMenuItem(value: 'priceHighLow', child: Text('Termahal')),
        ],
        onChanged: (val) {
          ref.read(filterProvider.notifier).update((s) => s.copyWith(sort: val));
          ref.read(bookNotifierProvider.notifier).fetchBooks(isRefresh: true);
        },
      ),
    );
  }
}

class GenreStatsWidget extends ConsumerWidget {
  const GenreStatsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(genreStatsProvider);
    final currentFilter = ref.watch(filterProvider);
    if (stats.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final item = stats[index];
          final String genreName = item['genre'] ?? "-";
          final bool isSelected = currentFilter.genre == genreName;
          return GestureDetector(
            onTap: () {
              if (isSelected) {
                ref.read(filterProvider.notifier).update((s) => s.copyWith(clearGenre: true));
              } else {
                ref.read(filterProvider.notifier).update((s) => s.copyWith(genre: genreName));
              }
              ref.read(bookNotifierProvider.notifier).fetchBooks(isRefresh: true);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange[800] : const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(genreName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("${item['count']} Buku", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
            ),
          );
        },
      ),
    );
  }
}