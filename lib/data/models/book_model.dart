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
      // Mapping _id dari API ke variable id
      id: json['_id']?.toString() ?? '', 
      title: json['title'] ?? 'Tanpa Judul',
      author: json['author'] ?? 'Anonim',
      // API ini biasanya pakai key 'image' atau 'cover'
      coverUrl: json['image'] ?? 'https://via.placeholder.com/150', 
      synopsis: json['summary'] ?? json['description'] ?? 'Tidak ada sinopsis',
      year: int.tryParse(json['year'].toString()) ?? 2020,
      price: int.tryParse(json['price'].toString()) ?? 50000, 
      genre: json['genre'] ?? 'Umum',
    );
  }
}