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
                    return const Center(child: Text("Belum ada informasi"));
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
                      return NewsCardWidget(news: news);
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
