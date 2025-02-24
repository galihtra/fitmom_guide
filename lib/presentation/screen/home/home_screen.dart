import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmom_guide/core/utils/dimensions.dart';
import 'package:fitmom_guide/core/utils/my_strings.dart';
import 'package:fitmom_guide/presentation/screen/news/news_list_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_images.dart';
import '../../../core/utils/style.dart';
import 'widget/cover_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
            const Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text("Home Content")),
                  NewsListScreen(),
                  Center(child: Text("Profile Content")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
