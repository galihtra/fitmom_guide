import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import '../../../../data/model/course/course.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/services/course/course_service.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../detail/course_detail.dart';

class FreeAccessListScreen extends StatefulWidget {
  const FreeAccessListScreen({super.key});

  @override
  State<FreeAccessListScreen> createState() => _FreeAccessListScreenState();
}

class _FreeAccessListScreenState extends State<FreeAccessListScreen> {
  final CourseService _courseService = CourseService();
  final LessonService _lessonService = LessonService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        title: const Text('Free Akses Program'),
        backgroundColor: MyColor.primaryColor,
      ),
      body: StreamBuilder<List<Course>>(
        stream: _courseService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final courses = snapshot.data ?? [];
          final freeCourses = courses
              .where((course) => course.isAvailable && course.isFree)
              .toList();

          if (freeCourses.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada kursus gratis yang tersedia',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: ListView.separated(
              itemCount: freeCourses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final course = freeCourses[index];

                return StreamBuilder<List<Lesson>>(
                  stream: _lessonService.getLessons(course.id, userId),
                  builder: (context, lessonSnapshot) {
                    if (lessonSnapshot.hasError) {
                      return const Card(
                        child: ListTile(
                          title: Text('Gagal memuat detail pelajaran'),
                        ),
                      );
                    }

                    final lessons = lessonSnapshot.data ?? [];
                    final totalLessons = lessons.length;
                    final completedLessons =
                        lessons.where((lesson) => lesson.isCompleted).length;
                    final double progress = totalLessons > 0
                        ? (completedLessons / totalLessons).clamp(0.0, 1.0)
                        : 0.0;
                    final int progressPercentage = (progress * 100).round();

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseDetailScreen(course: course),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Kursus
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: course.image.isNotEmpty
                                      ? Image.network(
                                          course.image,
                                          width: double.infinity,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _buildPlaceholderImage(),
                                        )
                                      : _buildPlaceholderImage(),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'GRATIS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Detail Kursus
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: MyColor.secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    course.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),

                                  // Progress Indicator
                                  Row(
                                    children: [
                                      Text(
                                        "Progress: $progressPercentage%",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "$completedLessons/$totalLessons pelajaran",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation(
                                        progress >= 0.7
                                            ? Colors.green
                                            : MyColor.secondaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.photo_library,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }
}
