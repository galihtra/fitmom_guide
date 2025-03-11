class Lesson {
  String id;
  String idCourse;
  String name;
  String description;
  String image;
  String urlVideo;
  String commentar;
  String ulasanPengguna;
  double rating;
  bool isCompleted; // Status user, tidak disimpan langsung di Firestore

  Lesson({
    required this.id,
    required this.idCourse,
    required this.name,
    required this.description,
    required this.image,
    required this.urlVideo,
    required this.commentar,
    required this.ulasanPengguna,
    required this.rating,
    this.isCompleted = false, // Default false jika belum ada data
  });

  factory Lesson.fromMap(Map<String, dynamic> map, String id) {
    return Lesson(
      id: id,
      idCourse: map['id_course'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      urlVideo: map['url_video'] ?? '',
      commentar: map['commentar'] ?? '',
      ulasanPengguna: map['ulasan_pengguna'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_course': idCourse,
      'name': name,
      'description': description,
      'image': image,
      'url_video': urlVideo,
      'commentar': commentar,
      'ulasan_pengguna': ulasanPengguna,
      'rating': rating,
    };
  }
}
