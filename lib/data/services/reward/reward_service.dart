import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> claimDailyReward() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    DocumentReference userRef = _firestore.collection('users').doc(userId);
    DocumentSnapshot userDoc = await userRef.get();

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (userDoc.exists) {
      // Ambil data user
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      String? lastClaimed = data['lastClaimed'];

      // Cek apakah sudah klaim hari ini
      if (lastClaimed == today) {
        return;
      }

      // Tambah poin dan update tanggal klaim
      await userRef.update({
        'points': (data['points'] ?? 0) + 1,
        'lastClaimed': today,
      });
    } else {
      // Jika user baru, buat data baru
      await userRef.set({
        'points': 1,
        'lastClaimed': today,
      });
    }
  }

  Future<int> getUserPoints() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return (userDoc['points'] ?? 0) as int;
    }
    return 0;
  }

  Future<String> getLastClaimedDate() async {
  String? userId = _auth.currentUser?.uid;
  if (userId == null) return "";

  DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();

  if (userDoc.exists && userDoc['lastClaimed'] != null) {
    return userDoc['lastClaimed'];
  }
  return "";
}

}
