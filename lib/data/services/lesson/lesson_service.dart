import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/lesson/lesson.dart';

class LessonService {
  final CollectionReference _lessonRef =
      FirebaseFirestore.instance.collection('lessons');

  Future<void> addLesson(Lesson lesson) async {
    await _lessonRef.add(lesson.toMap());
  }

  Future<void> updateLesson(String id, Lesson lesson) async {
    await _lessonRef.doc(id).update(lesson.toMap());
  }

  Future<void> deleteLesson(String id) async {
    await _lessonRef.doc(id).delete();
  }

  Stream<List<Lesson>> getLessons(String courseId) {
    return _lessonRef
        .where('id_course', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
