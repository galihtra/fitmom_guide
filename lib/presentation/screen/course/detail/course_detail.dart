import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini untuk akses Firestore
import 'package:fitmom_guide/presentation/screen/lesson/preview/preview_lesson.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Carousel Slider untuk slider gambar
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/model/course/course.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../../dashboard/dashboard_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  final bool useAffirmation;
  final String affirmationMessage;

  const CourseDetailScreen({
    super.key,
    required this.course,
    this.useAffirmation = false,
    this.affirmationMessage = '',
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final LessonService _lessonService = LessonService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _showReminderPopup();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.useAffirmation && widget.affirmationMessage.isNotEmpty) {
        _showAffirmationPopup(widget.affirmationMessage);
      }
    });
  }

  void _showAffirmationPopup(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    // Ambil nama dari Firestore
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String userName = (doc.data()?['name'] ?? 'Kamu').toString().trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 60, color: Colors.pink),
                const SizedBox(height: 16),
                Text(
                  "Afirmasi untukmu, $userName!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Lanjutkan",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showReminderPopup() async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    // Gunakan key berdasarkan course ID + tanggal hari ini
    final key = 'reminder_${widget.course.id}_$todayStr';

    final alreadyShown = prefs.getBool(key) ?? false;

    if (alreadyShown) return; // Sudah ditampilkan hari ini untuk course ini

    // Ambil data reminder dari Firestore
    final reminderSnapshot =
        await FirebaseFirestore.instance.collection('reminders').get();

    final imageUrls = reminderSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['imageUrl'] ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    if (imageUrls.isEmpty) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 500,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    aspectRatio: 16 / 9,
                  ),
                  items: imageUrls.map((imageUrl) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Simpan status bahwa popup sudah ditampilkan untuk course ini hari ini
    await prefs.setBool(key, true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        return false; // cegah back default
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0F3),
        appBar: AppBar(
          title: Text(widget.course.name),
          backgroundColor: const Color(0xFFFFF0F3),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.course.image.isNotEmpty
                  ? Image.network(widget.course.image,
                      width: double.infinity, height: 200, fit: BoxFit.cover)
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child:
                          Icon(Icons.image, size: 100, color: Colors.grey[600]),
                    ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.course.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(widget.course.description,
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),
                    const Text("Latihan",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              StreamBuilder<List<Lesson>>(
                stream: _lessonService.getLessons(widget.course.id, userId),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(child: Text('Error loading lessons'));
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  final lessons = snapshot.data!
                    ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: lesson.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    lesson.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image,
                                      size: 40, color: Colors.grey[600]),
                                ),
                          title: Text(lesson.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(lesson.description,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: lesson.isCompleted
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : const Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PreviewLessonScreen(lesson: lesson),
                              ),
                            );

                            setState(() {});
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
