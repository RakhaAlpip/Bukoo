import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/api_service.dart';
import '../data/models/book_model.dart';
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

final filterProvider = StateProvider<FilterState>((ref) => FilterState());
final apiServiceProvider = Provider((ref) => ApiService());
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final filter = ref.watch(filterProvider);

  return await api.getBooks(
    keyword: filter.keyword,
    sort: filter.sort,
  );
});