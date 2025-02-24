class CategoryNewsModel {
  final String id;
  final String category;

  CategoryNewsModel({required this.id, required this.category});

  Map<String, dynamic> toMap() => {'category': category};

  factory CategoryNewsModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryNewsModel(
      id: id,
      category: map['category'] ?? '',
    );
  }
}
