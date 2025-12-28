import 'package:dio/dio.dart';
import '../models/book_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://bukuacak-9bdcb4ef2605.herokuapp.com/api/v1',
    connectTimeout: const Duration(seconds: 10),
  ));

  Future<List<Book>> getBooks({
    String? sort,
    int? page,
    int? year,
    String? genre,
    String? keyword,
  }) async {
    try {
      final queryParameters = {
        if (sort != null && sort.isNotEmpty) 'sort': sort,
        if (page != null) 'page': page,
        if (year != null) 'year': year,
        if (genre != null && genre.isNotEmpty) 'genre': genre,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      };

      final response = await _dio.get('/book', queryParameters: queryParameters);
      
      print("RAW DATA FROM API: ${response.data}");

      if (response.statusCode == 200 && response.data['books'] != null) {
        final List listData = response.data['books'];
        return listData.map((e) => Book.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error Fetching Books: $e");
      return [];
    }
  }
  Future<List<Map<String, dynamic>>> getGenreStats() async {
    try {
      final response = await _dio.get('/stats/genre');
      if (response.statusCode == 200 && response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print("Error Fetching Stats: $e");
      return [];
    }
  }
}