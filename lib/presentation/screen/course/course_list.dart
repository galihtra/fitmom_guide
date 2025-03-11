import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:flutter/material.dart';
import '../../../data/model/course/course.dart';
import '../../../data/model/lesson/lesson.dart';
import '../../../data/services/course/course_service.dart';
import '../../../data/services/lesson/lesson_service.dart';
import 'add/add_course.dart';
import 'detail/course_detail.dart';

class CourseListScreen extends StatefulWidget {
  CourseListScreen({Key? key}) : super(key: key);

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CourseService _courseService = CourseService();

  final LessonService _lessonService = LessonService();

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Course>>(
        stream: _courseService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading courses'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCourses = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              itemCount: allCourses.length,
              itemBuilder: (context, index) {
                final course = allCourses[index];
                final bool isEnrolled = course.members.contains(userId);

                return StreamBuilder<List<Lesson>>(
                  stream: _lessonService.getLessons(
                      course.id, userId), // ✅ Perbaikan di sini
                  builder: (context, lessonSnapshot) {
                    if (lessonSnapshot.hasError) {
                      return const Center(child: Text('Error loading lessons'));
                    }
                    if (lessonSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final lessons = lessonSnapshot.data ?? [];
                    int totalLessons = lessons.length;
                    int completedLessons =
                        lessons.where((lesson) => lesson.isCompleted).length;
                    double progress = totalLessons > 0
                        ? (completedLessons / totalLessons)
                        : 0.0;
                    int progressPercentage = (progress * 100).toInt();

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      course.image.isNotEmpty
                                          ? Image.network(
                                              course.image,
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                    Icons.broken_image,
                                                    size: 60,
                                                    color: Colors.grey),
                                              ),
                                            )
                                          : Container(
                                              height: 150,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image,
                                                  size: 60, color: Colors.grey),
                                            ),
                                      if (!isEnrolled)
                                        Positioned.fill(
                                          child: Container(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            child: const Center(
                                              child: Icon(Icons.lock,
                                                  color: Colors.white,
                                                  size: 50),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Detail Course
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: MyColor.secondaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          course.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                        // Tambahkan teks jika belum terdaftar
                                        if (!isEnrolled) ...[
                                          const SizedBox(height: 5),
                                          const Text(
                                            "Hubungi admin untuk membuka pelatihan ini.",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 10),

                                        // Progress Bar hanya jika terdaftar
                                        if (isEnrolled)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Progress: $progressPercentage%",
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 5),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  minHeight: 8,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                    progressPercentage > 70
                                                        ? Colors.green
                                                        : MyColor
                                                            .secondaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Klik hanya jika sudah terdaftar
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: isEnrolled
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CourseDetailScreen(
                                                    course: course),
                                          ),
                                        );
                                        // Refresh UI setelah kembali dari LessonDetailScreen
                                        setState(() {});
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCourseScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
