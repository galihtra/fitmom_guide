import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/model/course/course.dart';
import '../../../data/model/lesson/lesson.dart';
import '../../../data/services/course/course_service.dart';
import '../../../data/services/lesson/lesson_service.dart';
import '../profile/widget/access_denied_dialog.dart';
import 'detail/course_detail.dart';
import 'free_access/free_access_list_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({Key? key}) : super(key: key);

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CourseService _courseService = CourseService();
  final LessonService _lessonService = LessonService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  List<Course> _sortedCourses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: StreamBuilder<List<Course>>(
        stream: _courseService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCourses = snapshot.data ?? [];

          // Filter kursus gratis
          final freeCourses = allCourses
              .where((c) => c.isAvailable && c.members.isEmpty)
              .toList();

          // Kursus yang sudah di-enroll (termasuk free)
          final unlockedCourses = allCourses
              .where((course) =>
                  course.members.contains(userId) &&
                  !(course.isAvailable && course.members.isEmpty))
              .toList();

          // Kursus terkunci
          final lockedCourses = allCourses
              .where((course) =>
                  !course.members.contains(userId) &&
                  !(course.isAvailable && course.members.isEmpty))
              .toList();

          // Inisialisasi _sortedCourses jika masih kosong
          if (_sortedCourses.isEmpty) {
            _sortedCourses = [...unlockedCourses, ...lockedCourses];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Free Access
                const Text(
                  'Free Akses Program',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Free Access Card
                if (freeCourses.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FreeAccessListScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MyColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: MyColor.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: MyColor.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mulai Belajar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${freeCourses.length} program gratis tersedia',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // All Programs Header
                const Text(
                  'Semua Program',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                // Course List with Reorderable Functionality
                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 16),
                  children: _sortedCourses.map((course) {
                    final bool isFree =
                        course.isAvailable && course.members.isEmpty;
                    final bool hasAccess =
                        course.members.contains(userId) || isFree;

                    return _buildCourseCard(course, hasAccess);
                  }).toList(),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final Course item = _sortedCourses.removeAt(oldIndex);
                      _sortedCourses.insert(newIndex, item);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(Course course, bool hasAccess) {
    return Card(
      key: ValueKey(course.id),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: hasAccess
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailScreen(course: course),
                  ),
                );
              }
            : () {
                showDialog(
                  context: context,
                  builder: (context) => AccessDeniedDialog(
                    courseName: course.name,
                    adminPhone: '6287738479403',
                  ),
                );
              },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<Lesson>>(
            stream: _lessonService.getLessons(course.id, userId),
            builder: (context, lessonSnapshot) {
              if (lessonSnapshot.hasError) {
                return const ListTile(
                  title: Text('Error memuat pelajaran'),
                );
              }

              final lessons = lessonSnapshot.data ?? [];
              final totalLessons = lessons.length;
              final completedLessons =
                  lessons.where((l) => l.isCompleted).length;
              final double progress = totalLessons > 0
                  ? (completedLessons / totalLessons).clamp(0.0, 1.0)
                  : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      // const Icon(Icons.drag_handle, color: Colors.grey),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          course.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: MyColor.primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.broken_image,
                                color: MyColor.primaryColor,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 60,
                              height: 60,
                              color: MyColor.primaryColor.withOpacity(0.1),
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (hasAccess) ...[
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        MyColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).round()}% selesai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '$completedLessons/$totalLessons pelajaran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text(
                      "Hubungi admin untuk mengakses program ini",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
