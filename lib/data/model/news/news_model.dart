// news_model.dart
class NewsModel {
  final String id;
  final String imageUrl;
  final String category;
  final String title;
  final String content;
  final String author;
  final DateTime publishDate;

  NewsModel({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.content,
    required this.author,
    required this.publishDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'category': category,
      'title': title,
      'content': content,
      'author': author,
      'publishDate': publishDate.toIso8601String(),
    };
  }

  factory NewsModel.fromMap(String id, Map<String, dynamic> map) {
    return NewsModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      author: map['author'] ?? '',
      publishDate: DateTime.parse(map['publishDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}
