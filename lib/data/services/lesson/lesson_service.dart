import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/lesson/lesson.dart';
import '../../model/lesson/lesson_folder.dart';
import '../../model/lesson/lesson_review.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tambah lesson ke dalam Firestore dengan ID otomatis
  Future<void> addLesson(String courseId, Lesson lesson) async {
    try {
      final docRef = _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(); // Buat ID otomatis

      lesson.id = docRef.id; // Simpan ID ke dalam objek Lesson

      await docRef
          .set(lesson.toMap()); // Simpan data lesson dengan ID yang benar
    } catch (e) {
      throw Exception("Failed to add lesson: $e");
    }
  }

  /// Update lesson berdasarkan ID
  Future<void> updateLesson(
      String courseId, String lessonId, Lesson lesson) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .update(lesson.toMap());
    } catch (e) {
      throw Exception("Failed to update lesson: $e");
    }
  }

  /// Hapus lesson berdasarkan ID
  Future<void> deleteLesson(String courseId, String lessonId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .delete();
    } catch (e) {
      throw Exception("Failed to delete lesson: $e");
    }
  }

  /// Ambil semua lesson berdasarkan user, dengan progres `isCompleted`
  Stream<List<Lesson>> getLessons(String courseId, String userId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('index') // Sort lesson berdasarkan index
        .snapshots()
        .asyncMap((snapshot) async {
      List<Lesson> lessons = [];

      for (var doc in snapshot.docs) {
        var lesson = Lesson.fromMap(doc.data(), doc.id);

        // Cek progres user di subkoleksi lesson_progress
        var userProgress = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lesson.id)
            .collection('lesson_progress')
            .doc(userId)
            .get();

        if (userProgress.exists) {
          lesson.isCompleted = userProgress.get('isCompleted') ?? false;
        }

        lessons.add(lesson);
      }
      return lessons;
    });
  }

  /// Update status `isCompleted` untuk user tertentu
  Future<void> updateLessonProgress(
      String courseId, String lessonId, String userId, bool isCompleted) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('lesson_progress')
          .doc(userId)
          .set({'isCompleted': isCompleted}, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to update lesson progress: $e");
    }
  }

  Future<void> resetAllLessonProgress(String courseId, String userId) async {
    final lessonsSnapshot = await _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .get();

    final batch = _firestore.batch();

    for (final lessonDoc in lessonsSnapshot.docs) {
      final progressRef =
          lessonDoc.reference.collection('lesson_progress').doc(userId);

      batch.set(progressRef, {'isCompleted': false}, SetOptions(merge: true));
    }

    await batch.commit();
  }

  /// Simpan rating & ulasan user
  Future<void> submitReview(String courseId, String lessonId, String userId,
      double rating, String comment) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('lesson_reviews')
          .doc(userId)
          .set({
        'userId': userId, // ✅ Simpan userId
        'rating': rating,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Review berhasil disimpan untuk userId: $userId");
    } catch (e) {
      throw Exception("Failed to submit review: $e");
    }
  }

  /// Ambil rating & ulasan user
  Future<LessonReview?> getReview(
      String courseId, String lessonId, String userId) async {
    try {
      var doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .collection('lesson_reviews')
          .doc(userId)
          .get();

      if (doc.exists) {
        return LessonReview.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch review: $e");
    }
  }

  Future<void> addUserPoints(String userId, int points) async {
    DocumentReference userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      int currentPoints = snapshot.get('points') ?? 0;
      transaction.update(userRef, {'points': currentPoints + points});
    });
  }

  Stream<List<LessonFolder>> getFolders(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('folders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LessonFolder.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<LessonFolder>> getSubfoldersByParentName(
      String courseId, String parentName) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('folders')
        .where('parent_folder_name', isEqualTo: parentName)
        .orderBy('index')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LessonFolder.fromMap(doc.data(), doc.id))
            .toList());
  }

// Pertahankan untuk query lessons
  Stream<List<Lesson>> getLessonsByFolderPath(
      String courseId, String folderPath, String userId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .where('folder_path', isEqualTo: folderPath)
        .orderBy('index')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Lesson> lessons = [];

      for (var doc in snapshot.docs) {
        var lesson = Lesson.fromMap(doc.data(), doc.id);

        // Check user progress
        var userProgress = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('lessons')
            .doc(lesson.id)
            .collection('lesson_progress')
            .doc(userId)
            .get();

        if (userProgress.exists) {
          lesson.isCompleted = userProgress.get('isCompleted') ?? false;
        }

        lessons.add(lesson);
      }
      return lessons;
    });
  }

  /// Get subfolders of a parent folder
  Stream<List<LessonFolder>> getSubfolders(
      String courseId, String parentFolderName) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('folders')
        .where('parent_folder_name', isEqualTo: parentFolderName)
        .orderBy('index') // Pastikan subfolder diurutkan
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LessonFolder.fromMap(doc.data(), doc.id))
            .toList());
  }
}
