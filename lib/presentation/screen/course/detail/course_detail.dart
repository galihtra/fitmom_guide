import 'package:flutter/material.dart';
import '../../../../data/model/course/course.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/services/course/course_service.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../../lesson/add/add_lesson.dart';
import '../../lesson/detail/lesson_detail_screen.dart';
import '../add_member/add_member_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  final CourseService _courseService = CourseService();
  final LessonService _lessonService = LessonService();

  CourseDetailScreen({required this.course});

  void _deleteCourse(BuildContext context) async {
    bool confirmDelete = await _showDeleteConfirmation(context);
    if (confirmDelete) {
      await _courseService.deleteCourse(course.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course.name} deleted successfully')),
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Course'),
            content: Text('Are you sure you want to delete ${course.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => EditCourseScreen(course: course)),
              // );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteCourse(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            course.image.isNotEmpty
                ? Image.network(course.image,
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
                  Text(course.name,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(course.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Text("Lessons",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            StreamBuilder<List<Lesson>>(
              stream: _lessonService.getLessons(course.id),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error loading lessons'));
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final lessons = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(lesson.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: lesson.isCompleted
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.radio_button_unchecked,
                                color: Colors.grey),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonDetailScreen(
                                  lesson: lesson), // Navigasi ke detail lesson
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddLessonScreen(courseId: course.id),
                      ),
                    );
                  },
                  heroTag: 'addLesson',
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () {
                    // tambah member
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddMemberScreen(courseId: course.id),
                      ),
                    );
                  },
                  heroTag: 'otherAction',
                  child: Icon(Icons.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
