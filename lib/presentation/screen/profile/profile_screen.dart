import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmom_guide/core/utils/dimensions.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:fitmom_guide/presentation/screen/profile/widget/card_profile_widget.dart';
import 'package:fitmom_guide/presentation/screen/profile/widget/contact_admin_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/style.dart';
import '../../../data/services/auth/auth_service.dart';
import '../../../data/services/reward/reward_service.dart';
import '../auth/login/login_screen.dart';
import 'widget/profile_avatar.dart';
import 'widget/reward_tracker.dart';
import 'widget/total_point.dart';
import 'widget/twibbon_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RewardService _rewardService = RewardService();
  final AuthService _authService = AuthService();

  List<bool> claimedDays = List.generate(7, (index) => false);
  final List<String> days = ["S", "M", "T", "W", "T", "F", "S"];

  String _name = "Loading...";
  String _timeAgo = "Just now";
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchRewardStatus();
  }

  /// **Fetch user data from Firestore**
  Future<void> _fetchUserData() async {
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
      setState(() => _name = "Error loading name");
    }
    setState(() => _isLoading = false);
  }

  /// **Calculate time ago from given DateTime**
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

  /// **Fetch reward status & claimed days**
  Future<void> _fetchRewardStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!userDoc.exists || !userDoc.data().toString().contains("claimedDays"))
      return;

    List<String> claimedDaysFromFirestore =
        List<String>.from(userDoc["claimedDays"] ?? []);
    DateTime today = DateTime.now();

    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    if (claimedDaysFromFirestore.isNotEmpty) {
      DateTime lastClaimDate = DateTime.parse(claimedDaysFromFirestore.last);
      if (lastClaimDate.isBefore(startOfWeek)) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"claimedDays": []});
        claimedDaysFromFirestore = [];
      }
    }

    setState(() {
      for (int i = 0; i < 7; i++) {
        DateTime day = startOfWeek.add(Duration(days: i));
        String dayStr = DateFormat('yyyy-MM-dd').format(day);
        int dayIndex = day.weekday % 7;
        claimedDays[dayIndex] = claimedDaysFromFirestore.contains(dayStr);
      }
    });
  }

  /// **Show logout confirmation dialog**
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
              await _authService.logout();
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
      backgroundColor: const Color(0xFFFFF0F3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: Dimensions.space10,
        backgroundColor: const Color(0xFFFFF0F3),
        title: Row(
          children: [
            ProfileAvatar(
                isLoading: _isLoading, profileImageUrl: _profileImageUrl),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: const [
                          Expanded(child: CardProfileWidget()),
                          SizedBox(width: 16),
                          Expanded(child: TotalPointWidget()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      RewardTracker(
                          claimedDays: claimedDays), // Tidak perlu Flexible
                      ContactAdminWidget(),
                      // DeleteAccountWidget(),
                      TwibbonCardWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
