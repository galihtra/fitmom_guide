class LessonFolder {
  final String id;
  final String name;
  final String? parentFolderName;
  final int? index; // Ubah menjadi nullable

  LessonFolder({
    required this.id,
    required this.name,
    this.parentFolderName,
    this.index, // Sekarang bisa null
  });

  factory LessonFolder.fromMap(Map<String, dynamic> map, String id) {
    return LessonFolder(
      id: id,
      name: map['name'] ?? '',
      parentFolderName: map['parent_folder_name'],
      index: map['index'], // Tidak perlu default value
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'parent_folder_name': parentFolderName,
      'index': index,
    };
  }
}
