import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/news/news_model.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _newsCollection = FirebaseFirestore.instance.collection('news');

  Future<void> addNews(NewsModel news) async {
    try {
      await _newsCollection.add(news.toMap());
    } catch (e) {
      throw Exception("Error adding news: $e");
    }
  }

  Future<void> updateNews(String id, NewsModel news) async {
    try {
      await _newsCollection.doc(id).update(news.toMap());
    } catch (e) {
      throw Exception("Error updating news: $e");
    }
  }

  Future<void> deleteNews(String id) async {
    try {
      await _newsCollection.doc(id).delete();
    } catch (e) {
      throw Exception("Error deleting news: $e");
    }
  }

  Stream<List<NewsModel>> getNewsList() {
    return _newsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return NewsModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
