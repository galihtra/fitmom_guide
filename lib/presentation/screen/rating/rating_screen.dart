import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../core/utils/my_color.dart';
import '../../../data/model/course/course.dart';
import '../../../data/model/lesson/lesson_review.dart';
import '../../../data/services/lesson/lesson_service.dart';
import '../course/detail/course_detail.dart';

class RatingScreen extends StatefulWidget {
  final String courseId;
  final Lesson lesson;
  final String userId;

  RatingScreen({
    required this.courseId,
    required this.lesson,
    required this.userId,
  });

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  TextEditingController _reviewController = TextEditingController();
  final LessonService _lessonService = LessonService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserReview();
  }

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

  Future<Course?> _fetchCourse() async {
    final doc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      return Course.fromMap(data, doc.id);
    }

    return null;
  }

  void _submitRating() async {
    await _lessonService.submitReview(
      widget.courseId,
      widget.lesson.id,
      widget.userId,
      _rating,
      _reviewController.text,
    );

    await _lessonService.addUserPoints(widget.userId, 5);

    _showCongratulationsPopup();
  }

  void _showCongratulationsPopup() async {
    final user = _auth.currentUser;
    final userId = user?.uid ?? '';
    String userName = 'Kamu';

    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data()?['name'] != null) {
      userName = doc['name'];
    }

    final affirmation =
        widget.lesson.useAffirmation ? widget.lesson.affirmationMessage : '';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, color: Colors.pink, size: 80),
                const SizedBox(height: 15),
                Text(
                  "Congratulations, $userName!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Selamat anda mendapatkan 5 poin! 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                if (affirmation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    affirmation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    final course = await _fetchCourse();
                    if (course != null && context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(
                            course: course,
                            affirmationMessage:
                                widget.lesson.affirmationMessage,
                            useAffirmation: widget.lesson.useAffirmation,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Lanjut Latihan",
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
                "Berikan Ulasan Untuk Mendapatkan 5 Poin",
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
