class Course {
  String id;
  String name;
  String description;
  String image;
  bool isAvailable;
  bool isFinished;
  final bool isFree;
  List<String> members; // List user ID yang memiliki akses ke course

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.isAvailable,
    required this.isFinished,
     required this.isFree,
    required this.members,
  });

  factory Course.fromMap(Map<String, dynamic> map, String id) {
    return Course(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      isFinished: map['isFinished'] ?? false,
      isFree: map['isFree'] ?? false,
      members: List<String>.from(map['members'] ?? []), // Ambil daftar member dari Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'isAvailable': isAvailable,
      'isFinished': isFinished,
      'isFree': isFree,
      'members': members, // Simpan daftar member
    };
  }
}
