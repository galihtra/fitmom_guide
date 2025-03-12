import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../detail/lesson_detail_screen.dart';

class PreviewLessonScreen extends StatefulWidget {
  final Lesson lesson;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  PreviewLessonScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  _PreviewLessonScreenState createState() => _PreviewLessonScreenState();
}

class _PreviewLessonScreenState extends State<PreviewLessonScreen> {
  double _averageRating = 0;
  int _reviewCount = 0;
  String _lessonDescription = "";
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchLessonData();
  }

  Future<String> _fetchUserName(String userId) async {
    if (userId.isEmpty) return "User Tidak Diketahui"; // Cek jika userId kosong

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      print("🔎 Mencari userId: $userId");

      if (userDoc.exists) {
        print("✅ Data user ditemukan: ${userDoc.data()}");
        return userDoc['name'] ?? "User Tidak Diketahui";
      } else {
        print("⚠ UserId tidak ditemukan di Firestore");
        return "User Tidak Diketahui";
      }
    } catch (e) {
      print("❌ Error mengambil nama user: $e");
      return "User Tidak Diketahui";
    }
  }

  Future<void> _fetchLessonData() async {
    try {
      // Ambil data lesson
      DocumentSnapshot lessonDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.lesson.idCourse)
          .collection('lessons')
          .doc(widget.lesson.id)
          .get();

      if (lessonDoc.exists) {
        setState(() {
          _lessonDescription =
              lessonDoc['description'] ?? "Deskripsi tidak tersedia";
        });
      }

      // Ambil semua ulasan
      QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.lesson.idCourse)
          .collection('lessons')
          .doc(widget.lesson.id)
          .collection('lesson_reviews')
          .get();

      double totalRating = 0;
      List<Map<String, dynamic>> reviews = [];

      for (var doc in reviewSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('rating') && data.containsKey('comment')) {
          double rating = (data['rating'] ?? 0).toDouble();
          totalRating += rating;

          String userId = data['userId'] ?? "";
          print("📌 Mengambil nama untuk userId: $userId");

          String userName = await _fetchUserName(userId);

          print("🔍 Nama user ditemukan: $userName");

          reviews.add({
            'user': userName,
            'comment': data['comment'] ?? "Tidak ada komentar",
          });
        }
      }

      setState(() {
        _averageRating = reviewSnapshot.docs.isNotEmpty
            ? totalRating / reviewSnapshot.docs.length
            : 0;
        _reviewCount = reviewSnapshot.docs.length;
        _reviews = reviews;
      });
    } catch (e) {
      print("❌ Error mengambil data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.lesson.image),
            ),
            const SizedBox(height: 10),
            Text(
              widget.lesson.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Icon(Icons.star, color: Colors.pink, size: 30),
                    Text(_averageRating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    const Icon(Icons.chat, color: Colors.pink, size: 30),
                    Text('$_reviewCount'),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: widget.lesson.isCompleted
                          ? Colors.green
                          : Colors.grey,
                      size: 30,
                    ),
                    Text(widget.lesson.isCompleted
                        ? "Telah Selesai"
                        : "Belum Selesai"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.pinkAccent),
              ),
              child: Text(
                _lessonDescription.isNotEmpty
                    ? _lessonDescription
                    : "Deskripsi tidak tersedia",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Ulasan Pengguna",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _reviews[index]['user'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Colors.pinkAccent),
                        ),
                        Text(_reviews[index]['comment']),
                        const Divider(color: Colors.pinkAccent),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LessonDetailScreen(
                          lesson: widget.lesson, userId: widget.userId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child:
                    const Text("MULAI", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
