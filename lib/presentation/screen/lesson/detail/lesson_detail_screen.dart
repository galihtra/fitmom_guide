import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../data/model/lesson/lesson.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  LessonDetailScreen({required this.lesson});

  @override
  _LessonDetailScreenState createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  YoutubePlayerController? _youtubeController; // Gunakan nullable

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
  }

  void _initializeYoutubePlayer() {
    if (widget.lesson.urlVideo.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.lesson.urlVideo);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            loop: false,
            forceHD: true,
          ),
        );
        setState(() {}); // Refresh UI setelah inisialisasi
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose(); // Gunakan nullable check
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pastikan controller sudah siap sebelum ditampilkan
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(widget.lesson.description,
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Text("User Comments",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  widget.lesson.commentar.isNotEmpty
                      ? Text(widget.lesson.commentar,
                          style: TextStyle(
                              fontSize: 14, fontStyle: FontStyle.italic))
                      : Text("No comments yet",
                          style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),
                  Text("User Rating",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 5),
                      Text(widget.lesson.rating > 0
                          ? widget.lesson.rating.toString()
                          : "No ratings yet"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
