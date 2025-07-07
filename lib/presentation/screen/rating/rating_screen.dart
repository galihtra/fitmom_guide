import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../core/utils/my_color.dart';
import '../../../data/model/lesson/lesson_review.dart';
import '../../../data/services/lesson/lesson_service.dart';

class RatingScreen extends StatefulWidget {
  final String courseId;
  final Lesson lesson;
  final String userId;

  const RatingScreen({
    Key? key,
    required this.courseId,
    required this.lesson,
    required this.userId,
  }) : super(key: key);

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final LessonService _lessonService = LessonService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchUserReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserReview() async {
    try {
      LessonReview? review = await _lessonService.getReview(
          widget.courseId, widget.lesson.id, widget.userId);
      if (review != null && mounted) {
        setState(() {
          _rating = review.rating;
          _reviewController.text = review.comment;
        });
      }
    } catch (e) {
      debugPrint("Error fetching review: $e");
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _lessonService.submitReview(
        widget.courseId,
        widget.lesson.id,
        widget.userId,
        _rating,
        _reviewController.text,
      );

      await _lessonService.addUserPoints(widget.userId, 5);

      if (mounted) {
        _showCongratulationsPopup();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showCongratulationsPopup() async {
    final user = _auth.currentUser;
    final userId = user?.uid ?? '';
    String userName = 'Kamu';

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data()?['name'] != null) {
        userName = doc['name'];
      }
    } catch (e) {
      debugPrint("Error fetching user name: $e");
    }

    final affirmation =
        widget.lesson.useAffirmation ? widget.lesson.affirmationMessage : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                onPressed: () {
                  // Close the modal and rating screen to return to lesson detail
                  // Navigator.of(context).pop(); // Close modal
                  // Navigator.of(context).pop(); // Close rating screen
                  // Navigator.of(context).pop(); // Close rating screen
                  // Navigator.of(context).pop();

                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Lanjut Latihan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        title: const Text('Beri Ulasan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.lesson.image),
                backgroundColor: Colors.grey[300],
                child: widget.lesson.image.isEmpty
                    ? const Icon(Icons.fitness_center, size: 40)
                    : null,
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
                    hintText: "Tulis ulasan Anda...",
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
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: Colors.pink.withOpacity(0.5),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Ulasan",
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
