import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/category/category_news_model.dart';

class CategoryNewsService {
  final CollectionReference _categoryCollection =
      FirebaseFirestore.instance.collection('category_news');

  Future<void> addCategory(CategoryNewsModel category) async {
    try {
      await _categoryCollection.add(category.toMap());
    } catch (e) {
      throw Exception("Error adding category: $e");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryCollection.doc(id).delete();
    } catch (e) {
      throw Exception("Error deleting category: $e");
    }
  }

  Stream<List<CategoryNewsModel>> getCategories() {
    return _categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CategoryNewsModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
