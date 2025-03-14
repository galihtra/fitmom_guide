import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../data/model/lesson/lesson_review.dart';
import '../../../data/services/lesson/lesson_service.dart';

class RatingScreen extends StatefulWidget {
  final String courseId;
  final Lesson lesson;
  final String userId;

  RatingScreen(
      {required this.courseId, required this.lesson, required this.userId});

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  TextEditingController _reviewController = TextEditingController();
  final LessonService _lessonService = LessonService();

  @override
  void initState() {
    super.initState();
    _fetchUserReview();
  }

  /// Ambil data review user dari Firestore
  void _fetchUserReview() async {
    LessonReview? review = await _lessonService.getReview(
        widget.courseId, widget.lesson.id, widget.userId);
    if (review != null) {
      setState(() {
        _rating = review.rating;
        _reviewController.text = review.comment;
      });
    }
  }

  /// Simpan review ke Firestore dan tampilkan popup
  void _submitRating() async {
    await _lessonService.submitReview(
      widget.courseId,
      widget.lesson.id,
      widget.userId,
      _rating,
      _reviewController.text,
    );

    _showCongratulationsPopup(); // ✅ Tampilkan popup setelah submit
  }

  /// ✅ Menampilkan popup bottom sheet "Congratulations"
  void _showCongratulationsPopup() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.celebration,
                    color: Colors.pink, size: 80), // 🎉 Ikon
                const SizedBox(height: 15),
                const Text(
                  "Congratulations!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Anda telah menyelesaikan latihan ini dengan sukses! 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup popup
                    Navigator.popUntil(context, (route) => route.isFirst);
                    // Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Lanjut ke Course",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.lesson.image),
              ),
              const SizedBox(height: 20),
              const Text(
                "Berikan Ulasan Untuk\nLatihan Hari ini",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.pink,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pinkAccent),
                ),
                child: TextField(
                  controller: _reviewController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Ulasan . . .",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Selanjutnya",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
