import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final String docId;

  const LikeButton({super.key, required this.docId});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    var likeDoc = await _firestore
        .collection('testimonials')
        .doc(widget.docId)
        .collection('likes')
        .doc(userId)
        .get();

    if (likeDoc.exists) {
      setState(() {
        isLiked = true;
      });
    }
  }

  Future<void> _toggleLike() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    DocumentReference testimonialRef =
        _firestore.collection('testimonials').doc(widget.docId);

    DocumentReference likeRef =
        testimonialRef.collection('likes').doc(userId);

    if (isLiked) {
      // Jika sudah like, maka unlike
      await likeRef.delete();
      await testimonialRef.update({
        'totalLikes': FieldValue.increment(-1),
      });
    } else {
      // Jika belum like, maka like
      await likeRef.set({'userId': userId});
      await testimonialRef.update({
        'totalLikes': FieldValue.increment(1),
      });
    }

    setState(() {
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggleLike,
      icon: Icon(
        Icons.favorite,
        color: isLiked ? Colors.pink : Colors.grey, // Warna berubah
      ),
    );
  }
}
