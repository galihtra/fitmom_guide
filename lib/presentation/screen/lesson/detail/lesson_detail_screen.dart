import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:slider_button/slider_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:audio_session/audio_session.dart';

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
  bool _isMuted = false;
  final CollectionReference _soundCollection =
      FirebaseFirestore.instance.collection('sounds');

  final ja.AudioPlayer _audioPlayer = ja.AudioPlayer();
  String? _currentlyPlaying;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.lesson.isCompleted;
    _isMuted = widget.lesson.soundEnabled;
    _initializeYoutubePlayer();
    _setupAudioPositionListener();
  }

  void _setupAudioPositionListener() {
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
  }

  void _initializeYoutubePlayer() {
    if (widget.lesson.urlVideo.isNotEmpty) {
      try {
        final videoId =
            YoutubePlayerController.convertUrlToId(widget.lesson.urlVideo);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController.fromVideoId(
            videoId: videoId,
            autoPlay: true,
            params: YoutubePlayerParams(
              mute: _isMuted,
              showControls: false,
              showFullscreenButton: true,
              loop: true,
              enableJavaScript: true,
              playsInline: false,
              strictRelatedVideos: false,
              showVideoAnnotations: false,
              enableKeyboard: false,
              origin: 'https://www.youtube-nocookie.com',
            ),
          );

          _youtubeController?.listen((event) {
            if (event.playerState == PlayerState.ended) {
              _youtubeController?.seekTo(seconds: 0);
              _youtubeController?.playVideo();
            }
          });
        }
      } catch (e) {
        print("Error initializing YouTube player: $e");
      }
    }
  }

  Future<void> _openYoutube() async {
    final url = widget.lesson.urlVideo.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL video tidak tersedia.')),
      );
      return;
    }

    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // langsung ke app YouTube/browser
    );

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka YouTube. Coba lagi ya.')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyelesaikan lesson: $e")),
      );
    }
  }

  Future<void> _playSound(String url) async {
    if (_currentlyPlaying == url) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlaying = null;
        _currentPosition = Duration.zero;
      });
    } else {
      try {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionMode: AVAudioSessionMode.defaultMode,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          androidAudioAttributes: AndroidAudioAttributes(
            usage: AndroidAudioUsage.media,
            contentType: AndroidAudioContentType.music,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ));

        await _audioPlayer.setUrl(url);
        _totalDuration = _audioPlayer.duration ?? Duration.zero;

        setState(() {
          _currentlyPlaying = url;
        });

        await _audioPlayer.play();
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.lesson.urlVideo.isNotEmpty && _youtubeController != null)
              Container(
                width: double.infinity,
                height: 630,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  aspectRatio: 16 / 9,
                ),
              )
            else if (widget.lesson.image.isNotEmpty)
              Image.network(
                widget.lesson.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fallback notice + CTA
                  // Container(
                  //   decoration: BoxDecoration(
                  //     gradient: const LinearGradient(
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //       colors: [Color(0xFFFFE4EC), Color(0xFFFFF0F3)],
                  //     ),
                  //     borderRadius: BorderRadius.circular(16),
                  //     border:
                  //         Border.all(color: const Color(0xFFFF8FB1), width: 1),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.pink.withOpacity(0.08),
                  //         blurRadius: 16,
                  //         offset: const Offset(0, 8),
                  //       ),
                  //     ],
                  //   ),
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 16, vertical: 14),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           Container(
                  //             decoration: BoxDecoration(
                  //               color: Colors.pink.shade50,
                  //               shape: BoxShape.circle,
                  //             ),
                  //             padding: const EdgeInsets.all(8),
                  //             child: const Icon(Icons.info_outline,
                  //                 color: Colors.pink, size: 20),
                  //           ),
                  //           const SizedBox(width: 10),
                  //           const Expanded(
                  //             child: Text(
                  //               'Jika video tidak bisa diputar, silakan klik tombol di bawah untuk membuka langsung di YouTube.',
                  //               style: TextStyle(fontSize: 13.5, height: 1.35),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 12),
                  //       SizedBox(
                  //         width: double.infinity,
                  //         child: ElevatedButton.icon(
                  //           onPressed: widget.lesson.urlVideo.trim().isEmpty
                  //               ? null
                  //               : _openYoutube,
                  //           icon: const Icon(Icons.play_circle_fill),
                  //           label: const Text('Buka Video'),
                  //           style: ElevatedButton.styleFrom(
                  //             elevation: 0,
                  //             foregroundColor: Colors.white,
                  //             backgroundColor: Colors.redAccent,
                  //             disabledBackgroundColor: Colors.grey.shade400,
                  //             padding: const EdgeInsets.symmetric(
                  //                 vertical: 14, horizontal: 16),
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //             textStyle: const TextStyle(
                  //               fontWeight: FontWeight.w700,
                  //               fontSize: 14.5,
                  //               letterSpacing: .2,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 12),
                  Text(widget.lesson.description,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Only show sound section if sound is enabled
                  if (widget.lesson.soundEnabled) ...[
                    const Text("Putar Musik", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    StreamBuilder(
                      stream: _soundCollection.snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var sounds = snapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: sounds.length,
                          itemBuilder: (context, index) {
                            var sound = sounds[index];
                            String soundUrl = sound['url'];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              title: Text(sound['name']),
                              subtitle: _currentlyPlaying == soundUrl
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        LinearProgressIndicator(
                                          value: _totalDuration.inMilliseconds >
                                                  0
                                              ? _currentPosition
                                                      .inMilliseconds /
                                                  _totalDuration.inMilliseconds
                                              : 0.0,
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.pink),
                                        ),
                                        Text(
                                          "${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    )
                                  : null,
                              trailing: IconButton(
                                icon: Icon(
                                  _currentlyPlaying == soundUrl
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed: () => _playSound(soundUrl),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  _isCompleted
                      ? const Center(
                          child: Text(
                            "✅ Latihan Selesai",
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

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String minutes = twoDigits(duration.inMinutes);
  String seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
