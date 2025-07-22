import 'package:flutter/material.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:fitmom_guide/data/model/lesson/lesson.dart';
import 'package:fitmom_guide/data/model/lesson/lesson_folder.dart';
import 'package:fitmom_guide/data/services/lesson/lesson_service.dart';
import 'package:fitmom_guide/presentation/screen/lesson/folder/folder_detail_screen.dart';

class MainFolderCard extends StatelessWidget {
  final LessonFolder folder;
  final bool isComplete;
  final String courseId;
  final bool useAffirmation;
  final String affirmationMessage;
  final String userId;
  final LessonService lessonService;
  final Function(String message) onShowAffirmation;

  const MainFolderCard({
    super.key,
    required this.folder,
    required this.isComplete,
    required this.courseId,
    required this.useAffirmation,
    required this.affirmationMessage,
    required this.userId,
    required this.lessonService,
    required this.onShowAffirmation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              builder: (context) => FolderDetailScreen(
                courseId: courseId,
                folder: folder,
              ),
            ),
          );

          if (useAffirmation &&
              affirmationMessage.isNotEmpty &&
              result == true) {
            onShowAffirmation(affirmationMessage);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MyColor.primaryColor.withOpacity(0.8),
                      MyColor.secondaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isComplete ? Icons.folder_open : Icons.folder,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // StreamBuilder<List<Lesson>>(
                    //   stream: lessonService.getLessons(courseId, userId),
                    //   builder: (context, snapshot) {
                    //     if (!snapshot.hasData) {
                    //       return Text(
                    //         'Memuat materi...',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: Colors.grey[500],
                    //         ),
                    //       );
                    //     }

                    //     final lessonCount = snapshot.data!
                    //         .where((lesson) => lesson.folderName == folder.name)
                    //         .length;

                    //     return Text(
                    //       '$lessonCount materi',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Colors.grey[500],
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
              Icon(
                isComplete ? Icons.check_circle : Icons.chevron_right,
                color: isComplete ? MyColor.primaryColor : Colors.grey[400],
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
