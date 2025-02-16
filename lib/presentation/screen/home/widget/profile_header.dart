import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmom_guide/core/utils/dimensions.dart';
import 'package:fitmom_guide/core/utils/my_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String _name = "Loading...";
  String _timeAgo = "Just now";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _name = userDoc["name"] ?? "No Name";
            _timeAgo =
                _calculateTimeAgo(user.metadata.creationTime ?? DateTime.now());
          });
        }
      }
    } catch (e) {
      setState(() {
        _name = "Error loading name";
      });
    }
  }

  String _calculateTimeAgo(DateTime time) {
    Duration difference = DateTime.now().difference(time);
    if (difference.inDays > 30) {
      return "${(difference.inDays / 30).floor()} month(s) ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} day(s) ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour(s) ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute(s) ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: Dimensions.profileRadius,
            backgroundColor: Colors.grey.shade200,
            child: SvgPicture.asset(
              MyImages.profile,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            _timeAgo,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
