import 'package:flutter/material.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:fitmom_guide/data/model/lesson/lesson.dart';
import 'package:fitmom_guide/data/services/lesson/lesson_service.dart';
import 'package:fitmom_guide/presentation/screen/lesson/preview/preview_lesson.dart';

class LessonsWithoutFolderWidget extends StatefulWidget {
  final String courseId;
  final String userId;
  final LessonService lessonService;
  final bool useAffirmation;
  final String affirmationMessage;
  final Function(String message) onShowAffirmation;

  const LessonsWithoutFolderWidget({
    super.key,
    required this.courseId,
    required this.userId,
    required this.lessonService,
    required this.useAffirmation,
    required this.affirmationMessage,
    required this.onShowAffirmation,
  });

  @override
  State<LessonsWithoutFolderWidget> createState() =>
      _LessonsWithoutFolderWidgetState();
}

class _LessonsWithoutFolderWidgetState
    extends State<LessonsWithoutFolderWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lesson>>(
      stream: widget.lessonService.getLessons(widget.courseId, widget.userId),
      builder: (context, lessonSnapshot) {
        if (lessonSnapshot.hasError) {
          return _buildErrorWidget('Gagal memuat materi');
        }

        if (!lessonSnapshot.hasData) {
          return _buildLoadingWidget();
        }

        final lessons = lessonSnapshot.data!
          ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

        final rootLessons = lessons
            .where((lesson) =>
                lesson.folderName == null || lesson.folderName!.isEmpty)
            .toList();

        if (rootLessons.isEmpty) return const SizedBox();

        final completedCount = rootLessons.where((l) => l.isCompleted).length;
        final allCompleted = completedCount == rootLessons.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  "Program Latihan",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '$completedCount/${rootLessons.length} selesai',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...rootLessons.map((lesson) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: MyColor.primaryColor.withOpacity(0.1),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PreviewLessonScreen(lesson: lesson),
                      ),
                    );

                    if (widget.useAffirmation &&
                        widget.affirmationMessage.isNotEmpty &&
                        result == true) {
                      widget.onShowAffirmation(widget.affirmationMessage);
                    }

                    setState(() {}); // Refresh
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100],
                            image: lesson.image.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(lesson.image),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: lesson.image.isEmpty
                              ? Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    size: 30,
                                    color: MyColor.primaryColor,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lesson.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        lesson.isCompleted
                            ? Icon(
                                Icons.check_circle,
                                color: allCompleted
                                    ? MyColor.primaryColor
                                    : Colors.grey[400],
                              )
                            : const Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.grey,
                              ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 40),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(MyColor.primaryColor),
        ),
      ),
    );
  }
}
