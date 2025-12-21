import 'package:dio/dio.dart';
import '../models/book_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    // Base URL baru
    baseUrl: 'https://bukuacak-9bdcb4ef2605.herokuapp.com/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<Book>> getBooks({
    String? sort,    // newest, oldest, titleAZ, dll
    String? keyword, // Search query
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
      };

      if (sort != null && sort.isNotEmpty) params['sort'] = sort;
      if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
      final response = await _dio.get('/book', queryParameters: params);

      print("API Response URL: ${response.realUri}");
      
      List<dynamic> listData = [];
      
      if (response.data is Map<String, dynamic>) {
        if (response.data['data'] != null) {
          listData = response.data['data'];
        }
      } else if (response.data is List) {
        listData = response.data;
      }

      return listData.map((e) => Book.fromJson(e)).toList();
      
    } catch (e) {
      print("API Error: $e");
      return []; 
    }
  }
}