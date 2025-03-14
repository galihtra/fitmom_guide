import 'package:flutter/material.dart';
import '../../../core/utils/dimensions.dart';
import '../../../data/model/news/news_model.dart';
import '../../../data/services/news/news_service.dart';
import '../../../data/services/category_news/category_news_service.dart';
import 'widget/category_filter_widget.dart';
import 'widget/news_card_widget.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  final CategoryNewsService _categoryService = CategoryNewsService();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: Padding(
        padding: const EdgeInsets.only(top: Dimensions.space10),
        child: Column(
          children: [
            CategoryFilterWidget(
              categoryService: _categoryService,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            Expanded(
              child: StreamBuilder<List<NewsModel>>(
                stream: _newsService.getNewsList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada berita"));
                  }

                  final newsList = snapshot.data!;
                  final filteredNews = _selectedCategory == null
                      ? newsList
                      : newsList
                          .where((news) => news.category == _selectedCategory)
                          .toList();

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredNews.length,
                    itemBuilder: (context, index) {
                      final news = filteredNews[index];

                      return Dismissible(
                        key: Key(news.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmationDialog(context);
                        },
                        onDismissed: (direction) async {
                          await _newsService.deleteNews(news.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Berita '${news.title}' berhasil dihapus")),
                          );
                        },
                        child: NewsCardWidget(news: news),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Konfirmasi Hapus"),
      content: const Text("Apakah Anda yakin ingin menghapus berita ini?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Batal"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Hapus"),
        ),
      ],
    ),
  );
}
