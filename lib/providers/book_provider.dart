import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/api_service.dart';
import '../data/models/book_model.dart';

// 1. State untuk menampung Filter
class FilterState {
  final String keyword;
  final String sort;

  FilterState({this.keyword = '', this.sort = 'newest'});

  FilterState copyWith({String? keyword, String? sort}) {
    return FilterState(
      keyword: keyword ?? this.keyword,
      sort: sort ?? this.sort,
    );
  }
}

// 2. Provider untuk Filter (Bisa diubah oleh UI)
final filterProvider = StateProvider<FilterState>((ref) => FilterState());

// 3. Provider API Service
final apiServiceProvider = Provider((ref) => ApiService());

// 4. Provider Data Buku (Otomatis refresh saat filterProvider berubah)
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final filter = ref.watch(filterProvider);

  // Panggil API dengan parameter dari filter
  return await api.getBooks(
    keyword: filter.keyword,
    sort: filter.sort,
  );
});