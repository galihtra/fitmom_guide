import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/model/lesson/lesson_folder.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../preview/preview_lesson.dart';

class FolderDetailScreen extends StatefulWidget {
  final String courseId;
  final LessonFolder folder;

  const FolderDetailScreen({
    required this.courseId,
    required this.folder,
  });

  @override
  _FolderDetailScreenState createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final _lessonService = LessonService();
  final _firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  late LessonFolder _currentFolder = widget.folder;
  bool _isLoading = false;
  String? _errorMessage;
  List<LessonFolder> _subfolders = [];

  @override
  void initState() {
    super.initState();
    _currentFolder = widget.folder;
    _loadSubfolders();
  }

  Future<void> _loadSubfolders() async {
    try {
      setState(() => _isLoading = true);
      final folders = await _lessonService
          .getSubfolders(
              widget.courseId, _currentFolder.fullPath ?? _currentFolder.name)
          .first;
      setState(() => _subfolders = folders);
    } catch (e) {
      _handleFirestoreError(e, 'loading subfolders');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleFirestoreError(dynamic error, String operation) {
    setState(() {
      _errorMessage = 'Error during $operation: ${error.toString()}';
    });
  }

  Future<bool> _isFolderComplete(String folderId, String folderPath) async {
    // Get lessons with user progress
    final lessons = await _lessonService
        .getLessonsByFolderPath(widget.courseId, folderPath, userId)
        .first;

    // Check if any lesson in this folder is incomplete
    if (lessons.any((lesson) => !lesson.isCompleted)) {
      return false;
    }

    // Check all subfolders recursively
    final subFolders = await _firestore
        .collection('courses')
        .doc(widget.courseId)
        .collection('folders')
        .where('parent_full_path', isEqualTo: folderPath)
        .get();

    for (final subFolderDoc in subFolders.docs) {
      final subFolder =
          LessonFolder.fromMap(subFolderDoc.data(), subFolderDoc.id);
      final isSubFolderComplete = await _isFolderComplete(
          subFolderDoc.id, subFolder.fullPath ?? subFolder.name);
      if (!isSubFolderComplete) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<bool>(
          future: _isFolderComplete(
              widget.folder.id, widget.folder.fullPath ?? widget.folder.name),
          builder: (context, snapshot) {
            final isComplete = snapshot.data ?? false;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isComplete)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                Text(
                  _currentFolder.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [MyColor.primaryColor, MyColor.secondaryColor],
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _errorMessage != null
          ? _buildErrorWidget()
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // === SUB FOLDERS ===
                    if (_subfolders.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                        child: Text(
                          "SUB FOLDER",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ..._subfolders.map((folder) {
                        return FutureBuilder<bool>(
                          future: _isFolderComplete(
                              folder.id, folder.fullPath ?? folder.name),
                          builder: (context, snapshot) {
                            final isComplete = snapshot.data ?? false;
                            return _buildFolderItem(folder, isComplete);
                          },
                        );
                      }).toList(),
                      SizedBox(height: 16),
                    ],

                    // === LESSONS ===
                    Expanded(
                      child: StreamBuilder<List<Lesson>>(
                        stream: _lessonService.getLessonsByFolderPath(
                            widget.courseId,
                            _currentFolder.fullPath ?? _currentFolder.name,
                            userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  MyColor.primaryColor,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _handleFirestoreError(
                                  snapshot.error!, 'loading lessons');
                            });
                            return Center(child: CircularProgressIndicator());
                          }

                          final lessons = snapshot.data ?? [];

                          if (lessons.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 60,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tidak Ada Materi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Belum ada materi yang tersedia dalam folder ini',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            physics: BouncingScrollPhysics(),
                            itemCount: lessons.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final lesson = lessons[index];
                              return _buildLessonCard(lesson);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubfolders,
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderItem(LessonFolder folder, bool isComplete) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.primaryColor.withOpacity(0.8),
                MyColor.secondaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.folder,
            color: Colors.white,
          ),
        ),
        title: Text(
          folder.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          isComplete ? Icons.check_circle : Icons.chevron_right,
          color: isComplete ? MyColor.primaryColor : Colors.grey[400],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FolderDetailScreen(
                courseId: widget.courseId,
                folder: folder,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewLessonScreen(lesson: lesson),
            ),
          );

          // Refresh state when returning from preview
          if (result == true && mounted) {
            setState(() {});
          }
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Lesson Thumbnail with Completion Badge
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
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
                      if (lesson.isCompleted)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: MyColor.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 16),

                  // Lesson Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
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

                  // Completion Status Icon
                  if (lesson.isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: MyColor.primaryColor,
                      size: 24,
                    ),
                ],
              ),
            ),

            // Completion Ribbon for completed lessons
            if (lesson.isCompleted)
              Positioned(
                top: 12,
                left: -20,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    color: MyColor.primaryColor,
                    child: Text(
                      'SELESAI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
