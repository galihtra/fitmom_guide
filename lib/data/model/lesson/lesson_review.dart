class LessonReview {
  String userId;
  double rating;
  String comment;

  LessonReview({
    required this.userId,
    required this.rating,
    required this.comment,
  });

  factory LessonReview.fromMap(Map<String, dynamic> map, String userId) {
    return LessonReview(
      userId: userId,
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}
