class LessonFolder {
  final String id;
  final String name;
  final String? parentFolderName;
  final String? fullPath;
  final int index; // Ubah dari nullable ke non-nullable dengan default value

  LessonFolder({
    required this.id,
    required this.name,
    this.parentFolderName,
    this.fullPath,
    this.index = 0, // Beri default value 0
  });

  factory LessonFolder.fromMap(Map<String, dynamic> map, String id) {
    return LessonFolder(
      id: id,
      name: map['name'] ?? '',
      parentFolderName: map['parent_folder_name'],
      fullPath: map['full_path'],
      index: map['index'] ?? 0, // Beri default value 0 jika null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'parent_folder_name': parentFolderName,
      'full_path': fullPath,
      'index': index,
    };
  }
}