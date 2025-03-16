import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class TestimonialService {
  final CollectionReference _testimonialCollection =
      FirebaseFirestore.instance.collection('testimonials');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  
  Stream<QuerySnapshot> getTestimonials() {
    return _testimonialCollection.snapshots();
  }

  Future<void> addTestimonial(Map<String, dynamic> data) async {
    try {
      // Upload gambar before & after ke Firebase Storage
      String beforeUrl = await _uploadImage(File(data['before']), 'before');
      String afterUrl = await _uploadImage(File(data['after']), 'after');

      // Simpan testimonial ke Firestore
      await _testimonialCollection.add({
        'name': data['name'],
        'description': data['description'],
        'before': beforeUrl,
        'after': afterUrl,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error adding testimonial: $e");
    }
  }

  Future<void> deleteTestimonial(String docId) async {
    try {
      DocumentSnapshot doc = await _testimonialCollection.doc(docId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        await _deleteImage(data['before']);
        await _deleteImage(data['after']);
        await _testimonialCollection.doc(docId).delete();
      }
    } catch (e) {
      print("Error deleting testimonial: $e");
    }
  }

  Future<String> _uploadImage(File file, String type) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_$type.jpg';
      Reference ref = _storage.ref().child('testimonials/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
}
