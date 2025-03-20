import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

class SoundScreen extends StatefulWidget {
  const SoundScreen({super.key});

  @override
  State<SoundScreen> createState() => _SoundScreenState();
}

class _SoundScreenState extends State<SoundScreen> {
  final CollectionReference _soundCollection =
      FirebaseFirestore.instance.collection('sounds');

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listener untuk memperbarui progress audio
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration ?? Duration.zero;
      });
    });

    // Loop audio otomatis saat selesai
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
      }
    });
  }

  Future<void> _addSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      String fileName = result.files.single.name;
      String? filePath = result.files.single.path;

      if (filePath != null) {
        Reference storageRef =
            FirebaseStorage.instance.ref().child('sounds/$fileName');
        UploadTask uploadTask = storageRef.putFile(File(filePath));

        // Tampilkan dialog loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Mengunggah Sound...",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );

        // Tunggu proses upload selesai
        await uploadTask.whenComplete(() => null);
        String downloadUrl = await storageRef.getDownloadURL();

        // Simpan ke Firestore
        await _soundCollection.add({
          'name': fileName,
          'url': downloadUrl,
        });

        // Tutup dialog loading setelah upload selesai
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sound berhasil ditambahkan!"),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Perbarui UI
        setState(() {});
      }
    }
  }

  /// Fungsi menghapus sound dari Firestore dan Storage
  Future<void> _deleteSound(String docId, String soundUrl) async {
    try {
      await FirebaseFirestore.instance.collection('sounds').doc(docId).delete();
      await FirebaseStorage.instance.refFromURL(soundUrl).delete();
    } catch (e) {
      print("Error deleting sound: $e");
    }
  }

  /// Fungsi memainkan atau menghentikan audio dengan loop
  Future<void> _playSound(String url) async {
    if (_currentlyPlaying == url) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlaying = null;
        _currentPosition = Duration.zero;
      });
    } else {
      try {
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

  /// **Otomatis stop audio ketika screen di-back**
  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// **UI Screen**
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sound List")),
      body: StreamBuilder(
        stream: _soundCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var sounds = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sounds.length,
            itemBuilder: (context, index) {
              var sound = sounds[index];
              String soundUrl = sound['url'];

              return Dismissible(
                key: Key(sound.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _deleteSound(sound.id, soundUrl);
                },
                child: ListTile(
                  title: Text(sound['name']),
                  subtitle: _currentlyPlaying == soundUrl
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: _totalDuration.inMilliseconds > 0
                                  ? _currentPosition.inMilliseconds /
                                      _totalDuration.inMilliseconds
                                  : 0.0,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.pink),
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
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Tambahkan Sound"),
                content: const Text("Pilih file audio untuk ditambahkan"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal"),
                  ),
                  ElevatedButton(
                    onPressed: _addSound,
                    child: const Text("Pilih File"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// **Format durasi jadi MM:SS**
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
