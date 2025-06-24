class Lesson {
  String id;
  String idCourse;
  String name;
  String description;
  String image;
  String urlVideo;
  bool isCompleted;
  String commentar;
  String ulasanPengguna;
  double rating;
  int index;
  bool useAffirmation; // New field
  String affirmationMessage; // New field

  Lesson({
    required this.id,
    required this.idCourse,
    required this.name,
    required this.description,
    required this.image,
    required this.urlVideo,
    required this.isCompleted,
    required this.commentar,
    required this.ulasanPengguna,
    required this.rating,
    required this.index,
    this.useAffirmation = false, // Default to false
    this.affirmationMessage = '', // Default empty
  });

  factory Lesson.fromMap(Map<String, dynamic> map, String id) {
    return Lesson(
      id: id,
      idCourse: map['id_course'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      urlVideo: map['url_video'] ?? '',
      isCompleted: map['is_completed'] ?? false,
      commentar: map['commentar'] ?? '',
      ulasanPengguna: map['ulasan_pengguna'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      index: map['index'] ?? 0,
      useAffirmation: map['use_affirmation'] ?? false,
      affirmationMessage: map['affirmation_message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_course': idCourse,
      'name': name,
      'description': description,
      'image': image,
      'url_video': urlVideo,
      'is_completed': isCompleted,
      'commentar': commentar,
      'ulasan_pengguna': ulasanPengguna,
      'index': index,
      'rating': rating,
      'use_affirmation': useAffirmation,
      'affirmation_message': affirmationMessage,
    };
  }
}