import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slider_button/slider_button.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/services/lesson/lesson_service.dart';
import '../../rating/rating_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final String userId;

  LessonDetailScreen({required this.lesson, required this.userId});

  @override
  _LessonDetailScreenState createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  YoutubePlayerController? _youtubeController;
  final LessonService _lessonService = LessonService();
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.lesson.isCompleted;
    _initializeYoutubePlayer();
  }

  void _initializeYoutubePlayer() {
    if (widget.lesson.urlVideo.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.lesson.urlVideo);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            loop: true,
            forceHD: true,
          ),
        );
      }
    }
  }

  void _markLessonAsCompleted() async {
    if (_isCompleted) return;

    try {
      await _lessonService.updateLessonProgress(
        widget.lesson.idCourse,
        widget.lesson.id,
        widget.userId,
        true,
      );

      if (mounted) {
        setState(() {
          _isCompleted = true;
        });

        // Navigasi ke RatingScreen tanpa menunggu, agar UI tetap responsif
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RatingScreen(
              lesson: widget.lesson,
              userId: widget.userId,
              courseId: widget.lesson.idCourse,
            ),
          ),
        );
      }
    } catch (e) {
      // Tampilkan error jika gagal menyimpan progres
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyelesaikan lesson: $e")),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.lesson.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white), // ✅ Warna ikon back
        systemOverlayStyle:
            SystemUiOverlayStyle.dark, // ✅ Pastikan status bar cocok
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.lesson.urlVideo.isNotEmpty && _youtubeController != null
                ? Container(
                    width: double.infinity,
                    height: 500,
                    child: YoutubePlayerBuilder(
                      player: YoutubePlayer(controller: _youtubeController!),
                      builder: (context, player) => player,
                    ),
                  )
                : widget.lesson.image.isNotEmpty
                    ? Image.network(
                        widget.lesson.image,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300],
                        child: Icon(Icons.image,
                            size: 100, color: Colors.grey[600]),
                      ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.lesson.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.lesson.description,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),

                  // Slide Button untuk Mark as Completed
                  _isCompleted
                      ? const Center(
                          child: Text(
                            "✅ Lesson Completed",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        )
                      : Center(
                          child: SliderButton(
                            action: () async {
                              _markLessonAsCompleted();
                              return true;
                            },
                            label: const Text(
                              "Geser Untuk Menyelesaikan",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            icon: const Icon(Icons.play_arrow,
                                color: Colors.white),
                            buttonColor: Colors.pink,
                            backgroundColor: Colors.white,
                            baseColor: Colors.pink,
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                        ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
