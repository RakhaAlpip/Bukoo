class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String synopsis;
  final int year;
  final int price;
  final String genre;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.synopsis,
    required this.year,
    required this.price,
    required this.genre,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? 'Tanpa Judul',
      author: json['author'] is Map ? (json['author']['name'] ?? 'Anonim') : 'Anonim',
      coverUrl: json['cover_image'] ?? 'https://via.placeholder.com/150',
      synopsis: json['summary'] ?? 'Tidak ada sinopsis.',
      year: json['year'] ?? 0,
      price: json['price'] ?? 0,
      genre: json['category'] is Map ? (json['category']['name'] ?? 'Umum') : 'Umum',
    );
  }
}