import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/book_model.dart';
import '../data/services/api_service.dart';

class FilterState {
  final String keyword;
  final String sort;
  final String? genre;

  FilterState({this.keyword = '', this.sort = 'newest', this.genre});

  FilterState copyWith({String? keyword, String? sort, String? genre, bool clearGenre = false}) {
    return FilterState(
      keyword: keyword ?? this.keyword,
      sort: sort ?? this.sort,
      genre: clearGenre ? null : (genre ?? this.genre),
    );
  }
}

final filterProvider = StateProvider<FilterState>((ref) => FilterState());

class BookState {
  final List<Book> books;
  final int currentPage;
  final bool isLoading;
  final bool hasMore;

  BookState({required this.books, required this.currentPage, required this.isLoading, required this.hasMore});

  BookState copyWith({List<Book>? books, int? currentPage, bool? isLoading, bool? hasMore}) {
    return BookState(
      books: books ?? this.books,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class BookNotifier extends StateNotifier<BookState> {
  final Ref _ref;
  final ApiService _apiService = ApiService();
  BookNotifier(this._ref) : super(BookState(books: [], currentPage: 1, isLoading: false, hasMore: true)) {
    fetchBooks();
  }
    Future<void> fetchBooks({bool isRefresh = false}) async {
    if (state.isLoading || (!state.hasMore && !isRefresh)) return;
    if (isRefresh) state = state.copyWith(currentPage: 1, hasMore: true, books: []);
    state = state.copyWith(isLoading: true);
    final filter = _ref.read(filterProvider); 
    try {
      final newBooks = await _apiService.getBooks(
        page: state.currentPage,
        keyword: filter.keyword,
        sort: filter.sort,
        genre: filter.genre,
      );
      if (newBooks.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
      } else {
        state = state.copyWith(
          books: [...state.books, ...newBooks],
          currentPage: state.currentPage + 1,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final bookNotifierProvider = StateNotifierProvider<BookNotifier, BookState>((ref) => BookNotifier(ref));
final genreStatsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final books = ref.watch(bookNotifierProvider).books;
  if (books.isEmpty) return [];
  final Map<String, int> counts = {};
  for (var book in books) {
    final g = book.genre ?? 'Lainnya';
    counts[g] = (counts[g] ?? 0) + 1;
  }
  return counts.entries.map((e) => {'genre': e.key, 'count': e.value}).toList();
});