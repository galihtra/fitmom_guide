import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Untuk download gambar
import 'package:path_provider/path_provider.dart'; // Untuk akses direktori sementara
import 'package:share_plus/share_plus.dart'; // Untuk share teks dan gambar

import '../../../../data/model/news/news_model.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({super.key, required this.news});

  Future<void> _shareNews(BuildContext context) async {
    try {
      // Download gambar dari URL
      final response = await http.get(Uri.parse(news.imageUrl));
      final bytes = response.bodyBytes;

      // Simpan gambar ke direktori sementara
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/news_image.jpg');
      await file.writeAsBytes(bytes);

      // Share gambar dan teks berita
      Share.shareFiles([file.path], text: '${news.title}\n\n${news.content}\n\nBaca Selengkapnya di Aplikasi Fitmom Guide!');
    } catch (e) {
      // Tampilkan error jika terjadi kesalahan saat download atau share
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share news: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        title: Text(news.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: () => _shareNews(context),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                news.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(label: Text(news.category)),
                  Text(
                    news.author,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                news.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
