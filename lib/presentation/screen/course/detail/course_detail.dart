import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmom_guide/presentation/screen/lesson/preview/preview_lesson.dart';
import 'package:flutter/material.dart';
import '../../../../data/model/course/course.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/services/lesson/lesson_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final LessonService _lessonService = LessonService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.course.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(widget.course.description, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  const Text("Latihan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

                // Urutkan lessons berdasarkan nilai index
                final lessons = snapshot.data!..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                child: Icon(Icons.image, size: 40, color: Colors.grey[600]),
                              ),
                        title: Text(lesson.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lesson.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: lesson.isCompleted
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviewLessonScreen(lesson: lesson),
                            ),
                          );

                          // Refresh UI setelah kembali dari LessonDetailScreen
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
    );
  }
}
