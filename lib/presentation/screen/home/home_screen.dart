import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmom_guide/core/utils/dimensions.dart';
import 'package:fitmom_guide/core/utils/my_strings.dart';
import 'package:fitmom_guide/presentation/screen/news/news_list_screen.dart';
import 'package:fitmom_guide/presentation/screen/testimonial/testimonial_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_images.dart';
import '../../../core/utils/style.dart';
import '../../../data/services/reward/reward_service.dart';
import '../course/course_list.dart';
import 'widget/cover_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RewardService _rewardService = RewardService();
  int userPoints = 0;
  String _name = "Loading...";
  String _timeAgo = "Just now";
  String? _profileImageUrl;
  bool _isLoading = true;
  bool _hasClaimedToday = false;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClaimStatus();
    });
  }

  Future<void> _checkClaimStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Cek apakah field "claimedDays" ada dan valid
    List<String> claimedDays = [];
    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (userData.containsKey("claimedDays") &&
          userData["claimedDays"] is List) {
        claimedDays = List<String>.from(userData["claimedDays"]);
      }
    }

    // Jika belum klaim hari ini, tampilkan modal
    if (!claimedDays.contains(todayStr)) {
      _showRewardModal();
    }
  }

  void _showRewardModal() {
    _confettiController.play(); // Memulai animasi confetti
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildRewardModal(),
    );
  }

  Future<void> _claimDailyReward() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Update Firestore agar user tidak bisa klaim dua kali dalam sehari
    String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "claimedDays": FieldValue.arrayUnion([todayStr])
    });

    // Tambahkan reward ke user
    await _rewardService.claimDailyReward();
    int points = await _rewardService.getUserPoints();

    setState(() {
      userPoints = points;
      _hasClaimedToday = true;
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Selamat! Anda mendapatkan 1 poin hari ini 🎉"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildRewardModal() {
    List<String> quotes = [
      "Tetap semangat, hari ini adalah kesempatan baru!",
      "Keberhasilan dimulai dengan langkah kecil setiap hari!",
      "Jangan menyerah, impianmu lebih dekat dari yang kau kira!",
      "Setiap usaha kecilmu hari ini akan berbuah manis nanti!",
      "Hari yang baik dimulai dengan semangat dan senyuman!",
    ];
    String randomQuote = (quotes..shuffle()).first;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🎉 Daily Streak! 🎉",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  randomQuote,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _claimDailyReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    "Ayo mulai latihan",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Tambah Icon Hadiah
          Positioned(
            top: -40,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child:
                  Icon(Icons.card_giftcard, color: Colors.pinkAccent, size: 50),
            ),
          ),
          // Confetti Animation
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.3,
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF0F3),
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                coverImage(),
                Positioned(
                  top: Dimensions.topProfile,
                  child: Padding(
                    padding: const EdgeInsets.only(left: Dimensions.space20),
                    child: Column(
                      children: [
                        _isLoading
                            ? const CircleAvatar(
                                radius: Dimensions.profileRadius,
                                backgroundColor: Colors.grey,
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              )
                            : CircleAvatar(
                                radius: Dimensions.profileRadius,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: _profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null,
                                child: _profileImageUrl == null
                                    ? SvgPicture.asset(MyImages.profile,
                                        fit: BoxFit.cover)
                                    : null,
                              ),
                        const SizedBox(height: Dimensions.space10),
                        Text(
                          _name,
                          style: boldMediumLarge,
                        ),
                        Text(
                          _timeAgo,
                          style: regularMediumLargeSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.space100),
            const TabBar(
              labelColor: MyColor.secondaryColor,
              unselectedLabelColor: MyColor.contentTextColor,
              indicatorColor: MyColor.secondaryColor,
              tabs: [
                Tab(text: MyStrings.pelatihan),
                Tab(text: MyStrings.beritaDanTips),
                Tab(text: MyStrings.testimoni),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  CourseListScreen(),
                  const NewsListScreen(),
                  const TestimonialScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
