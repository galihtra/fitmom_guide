import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/course/course.dart';

class CourseService {
  final CollectionReference _courseRef =
      FirebaseFirestore.instance.collection('courses');

  Future<void> addCourse(Course course) async {
    await _courseRef.add(course.toMap()..['members'] = []);
  }

  Future<void> updateCourse(String id, Course course) async {
    await _courseRef.doc(id).update(course.toMap());
  }

  Future<void> deleteCourse(String id) async {
    await _courseRef.doc(id).delete();
  }

  Future<void> addMemberToCourse(String courseId, String userId) async {
    final docRef = _courseRef.doc(courseId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(docRef);
      if (!docSnapshot.exists) {
        throw Exception("Course not found");
      }

      final data = docSnapshot.data() as Map<String, dynamic>?; // Casting
      List<String> members = (data != null && data.containsKey('members'))
          ? List<String>.from(data['members'] as List<dynamic>) // Konversi aman
          : [];

      if (!members.contains(userId)) {
        members.add(userId);
        transaction.update(docRef, {'members': members});
      }
    });
  }

  Future<void> removeMemberFromCourse(String courseId, String userId) async {
    await _courseRef.doc(courseId).update({
      'members': FieldValue.arrayRemove([userId]) // Hapus user dari array
    });
  }

  Future<bool> isUserInCourse(String courseId, String userId) async {
    final docSnapshot = await _courseRef.doc(courseId).get();
    if (!docSnapshot.exists) return false;

    final data = docSnapshot.data() as Map<String, dynamic>?; // Casting ke Map<String, dynamic>
    List<String> members = (data != null && data.containsKey('members'))
        ? List<String>.from(data['members'] as List<dynamic>) // Konversi aman
        : [];

    return members.contains(userId);
  }

  Stream<List<Course>> getCourses() {
    return _courseRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}
