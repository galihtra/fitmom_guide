import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:fitmom_guide/presentation/screen/lesson/preview/preview_lesson.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/model/course/course.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/model/lesson/lesson_folder.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../lesson/folder/folder_detail_screen.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final Map<String, bool> _folderExpansionStates = {};
  bool _hasShownAffirmation = false;

  @override
  void initState() {
    super.initState();
    _showReminderPopup();
  }

  Future<bool> _isFolderComplete(String folderId, String folderName) async {
    // Handle special case for root lessons
    if (folderName.isEmpty) {
      final lessons =
          await _lessonService.getLessons(widget.course.id, userId).first;
      final rootLessons = lessons
          .where((lesson) =>
              lesson.folderName == null || lesson.folderName!.isEmpty)
          .toList();

      // Return true only if there are lessons AND all are completed
      return rootLessons.isNotEmpty &&
          rootLessons.every((lesson) => lesson.isCompleted);
    }

    // Original logic for folders
    final lessons =
        await _lessonService.getLessons(widget.course.id, userId).first;
    final folderLessons =
        lessons.where((lesson) => lesson.folderName == folderName).toList();

    // Return false if no lessons or any incomplete
    if (folderLessons.isEmpty ||
        folderLessons.any((lesson) => !lesson.isCompleted)) {
      return false;
    }

    // Check subfolders
    final subFolders = await _firestore
        .collection('courses')
        .doc(widget.course.id)
        .collection('folders')
        .where('parent_folder_name', isEqualTo: folderName)
        .get();

    for (final subFolderDoc in subFolders.docs) {
      final subFolder =
          LessonFolder.fromMap(subFolderDoc.data(), subFolderDoc.id);
      final isSubFolderComplete =
          await _isFolderComplete(subFolderDoc.id, subFolder.name);
      if (!isSubFolderComplete) {
        return false;
      }
    }

    return true;
  }

  void _showAffirmationPopup(String message) async {
    if (_hasShownAffirmation) return;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    final doc = await _firestore.collection('users').doc(userId).get();
    String userName = (doc.data()?['name'] ?? 'Kamu').toString().trim();

    _hasShownAffirmation = true;

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
                const Icon(Icons.favorite,
                    size: 60, color: MyColor.primaryColor),
                const SizedBox(height: 16),
                Text(
                  "Afirmasi untukmu, $userName!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyColor.primaryColor,
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
                    backgroundColor: MyColor.primaryColor,
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
    final key = 'reminder_${widget.course.id}_$todayStr';
    final alreadyShown = prefs.getBool(key) ?? false;

    if (alreadyShown) return;

    final reminderSnapshot = await _firestore.collection('reminders').get();

    final imageUrls = reminderSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['imageUrl'] ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    if (imageUrls.isEmpty) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        fit: BoxFit.cover,
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
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

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
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.course.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Section
              Hero(
                tag: 'course-${widget.course.id}',
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.course.image.isNotEmpty
                      ? ClipRRect(
                          child: Image.network(
                            widget.course.image,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.fitness_center,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                ),
              ),

              // Course Info Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.course.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "FOLDER LATIHAN",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MyColor.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Divider(
                      color: Colors.grey[300],
                      thickness: 1,
                      height: 24,
                    ),
                  ],
                ),
              ),

              // Main Folders Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder<List<LessonFolder>>(
                  stream: _lessonService.getFolders(widget.course.id),
                  builder: (context, folderSnapshot) {
                    if (folderSnapshot.hasError) {
                      return _buildErrorWidget('Gagal memuat folder');
                    }

                    if (!folderSnapshot.hasData) {
                      return _buildLoadingWidget();
                    }

                    // Filter only main folders (without parent folders)
                    final mainFolders = folderSnapshot.data!
                        .where((folder) =>
                            folder.parentFolderName == null ||
                            folder.parentFolderName!.isEmpty)
                        .toList()
                      ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

                    return Column(
                      children: [
                        // Main Folders
                        ...mainFolders.map((folder) {
                          return FutureBuilder<bool>(
                            future: _isFolderComplete(folder.id, folder.name),
                            builder: (context, completionSnapshot) {
                              final isComplete =
                                  completionSnapshot.data ?? false;
                              return _buildMainFolderCard(folder, isComplete);
                            },
                          );
                        }).toList(),

                        // Lessons without folder
                        _buildLessonsWithoutFolder(),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainFolderCard(LessonFolder folder, bool isComplete) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
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
                courseId: widget.course.id,
                folder: folder,
              ),
            ),
          );

          if (widget.useAffirmation &&
              widget.affirmationMessage.isNotEmpty &&
              result == true) {
            _showAffirmationPopup(widget.affirmationMessage);
          }
          setState(() {});
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
              SizedBox(width: 16),
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
                    SizedBox(height: 4),
                    StreamBuilder<List<Lesson>>(
                      stream:
                          _lessonService.getLessons(widget.course.id, userId),
                      builder: (context, lessonSnapshot) {
                        if (!lessonSnapshot.hasData) {
                          return Text(
                            'Memuat materi...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          );
                        }

                        final lessonCount = lessonSnapshot.data!
                            .where((lesson) => lesson.folderName == folder.name)
                            .length;

                        return Text(
                          '$lessonCount ${lessonCount == 1 ? 'materi' : 'materi'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        );
                      },
                    ),
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

  Widget _buildLessonsWithoutFolder() {
    return StreamBuilder<List<Lesson>>(
      stream: _lessonService.getLessons(widget.course.id, userId),
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

        if (rootLessons.isEmpty) {
          return SizedBox();
        }

        // Hitung jumlah materi yang sudah selesai
        final completedCount = rootLessons.where((l) => l.isCompleted).length;
        final allCompleted = completedCount == rootLessons.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
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
                Spacer(),
                if (rootLessons.isNotEmpty)
                  Text(
                    '$completedCount/${rootLessons.length} selesai',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            ...rootLessons.map((lesson) {
              return Card(
                margin: EdgeInsets.only(bottom: 12),
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
                        builder: (context) =>
                            PreviewLessonScreen(lesson: lesson),
                      ),
                    );

                    if (widget.useAffirmation &&
                        widget.affirmationMessage.isNotEmpty &&
                        result == true) {
                      _showAffirmationPopup(widget.affirmationMessage);
                    }
                    setState(() {});
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
                        SizedBox(width: 16),
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
                              SizedBox(height: 4),
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
                        // Hanya tampilkan centang jika materi ini selesai
                        lesson.isCompleted
                            ? Icon(
                                Icons.check_circle,
                                color: allCompleted
                                    ? MyColor.primaryColor
                                    : Colors.grey[400],
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                color: Colors.grey[400],
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

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
