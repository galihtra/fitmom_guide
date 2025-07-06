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
import '../widget/error_widget.dart';
import '../widget/fullscreen_image_view.dart';
import '../widget/lessons_without_folder.dart';
import '../widget/loading_widget.dart';
import '../widget/main_folder_card.dart';

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
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _showReminderPopup();
  }

  Future<bool> _isFolderComplete(String folderId, String folderName) async {
    if (folderName.isEmpty) {
      final lessons =
          await _lessonService.getLessons(widget.course.id, userId).first;
      final rootLessons = lessons
          .where((lesson) =>
              lesson.folderName == null || lesson.folderName!.isEmpty)
          .toList();
      return rootLessons.isNotEmpty &&
          rootLessons.every((lesson) => lesson.isCompleted);
    }

    final lessons =
        await _lessonService.getLessons(widget.course.id, userId).first;
    final folderLessons =
        lessons.where((lesson) => lesson.folderName == folderName).toList();

    if (folderLessons.isEmpty ||
        folderLessons.any((lesson) => !lesson.isCompleted)) {
      return false;
    }

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

  Future<void> _showResetConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress Latihan'),
        content: const Text(
            'Apakah Anda yakin ingin mereset semua progress latihan di kursus ini? '
            'Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _resetCourseProgress();
    }
  }

  Future<void> _resetCourseProgress() async {
    if (_isResetting) return;

    setState(() => _isResetting = true);

    try {
      await _lessonService.resetAllLessonProgress(widget.course.id, userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress latihan berhasil direset')),
      );
      setState(() {}); // Untuk me-refresh tampilan
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mereset progress')),
      );
    } finally {
      setState(() => _isResetting = false);
    }
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
          title: StreamBuilder<List<Lesson>>(
            stream: _lessonService.getLessons(widget.course.id, userId),
            builder: (context, snapshot) {
              final hasCompletedLessons =
                  snapshot.data?.any((l) => l.isCompleted) ?? false;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.course.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasCompletedLessons)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _showResetConfirmation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.restart_alt,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          centerTitle: false,
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
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.course.image,
                child: Stack(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: widget.course.image.isNotEmpty
                          ? ClipRRect(
                              child: Image.network(
                                widget.course.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
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
                    // 🔽 Tombol di pojok kanan bawah
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.fullscreen,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullscreenImageView(
                                  imageUrl: widget.course.image,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                    const SizedBox(height: 12),
                    Text(
                      widget.course.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder<List<LessonFolder>>(
                  stream: _lessonService.getFolders(widget.course.id),
                  builder: (context, folderSnapshot) {
                    if (folderSnapshot.hasError) {
                      return const ErrorView(message: 'Gagal memuat data');
                    }

                    if (!folderSnapshot.hasData) {
                      return const LoadingView();
                    }

                    final mainFolders = folderSnapshot.data!
                        .where((folder) =>
                            folder.parentFolderName == null ||
                            folder.parentFolderName!.isEmpty)
                        .toList()
                      ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

                    return Column(
                      children: [
                        ...mainFolders.map((folder) {
                          return FutureBuilder<bool>(
                            future: _isFolderComplete(folder.id, folder.name),
                            builder: (context, completionSnapshot) {
                              final isComplete =
                                  completionSnapshot.data ?? false;
                              return MainFolderCard(
                                folder: folder,
                                isComplete: isComplete,
                                courseId: widget.course.id,
                                useAffirmation: widget.useAffirmation,
                                affirmationMessage: widget.affirmationMessage,
                                userId: userId,
                                lessonService: _lessonService,
                                onShowAffirmation: _showAffirmationPopup,
                              );
                            },
                          );
                        }).toList(),
                        LessonsWithoutFolderWidget(
                          courseId: widget.course.id,
                          userId: userId,
                          lessonService: _lessonService,
                          useAffirmation: widget.useAffirmation,
                          affirmationMessage: widget.affirmationMessage,
                          onShowAffirmation: _showAffirmationPopup,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
