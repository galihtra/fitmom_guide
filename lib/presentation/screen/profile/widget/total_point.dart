import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/style.dart';

class TotalPointWidget extends StatefulWidget {
  const TotalPointWidget({super.key});

  @override
  State<TotalPointWidget> createState() => _TotalPointWidgetState();
}

class _TotalPointWidgetState extends State<TotalPointWidget> {
  int _totalPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTotalPoints();
  }

  Future<void> _fetchTotalPoints() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data().toString().contains("points")) {
        setState(() {
          _totalPoints = userDoc["points"] ?? 0;
        });
      }
    } catch (e) {
      setState(() {
        _totalPoints = 0;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pinkAccent.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 40),
              const SizedBox(width: 4),
              Text(
                _isLoading ? "Loading..." : "$_totalPoints",
                style: boldLarge.copyWith(
                    color: MyColor.secondaryColor, fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Total Poin",
          ),
        ],
      ),
    );
  }
}
