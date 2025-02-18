import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmom_guide/core/utils/dimensions.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/utils/my_images.dart';
import '../../../core/utils/style.dart';
import '../../../data/services/auth/auth_service.dart';
import '../auth/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "Loading...";
  String _timeAgo = "Just now";
  String? _profileImageUrl;
  bool _isLoading = true;

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
            _profileImageUrl = userDoc["profileImage"];
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
    setState(() => _isLoading = false);
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: Dimensions.space10,
        title: Row(
          children: [
            _isLoading
                ? const CircleAvatar(
                    radius: Dimensions.profileRadiusSmalll,
                    backgroundColor: Colors.grey,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : CircleAvatar(
                    radius: Dimensions.profileRadiusSmalll,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? SvgPicture.asset(MyImages.profile, fit: BoxFit.cover)
                        : null,
                  ),
            const SizedBox(width: Dimensions.space10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLoading ? "Loading..." : _name,
                      style: boldMediumLarge),
                  Text(_isLoading ? "Loading..." : _timeAgo,
                      style: regularMediumLargeSecondary),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: MyColor.secondaryColor),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: const Center(
        child: Text("Profile Screen", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
