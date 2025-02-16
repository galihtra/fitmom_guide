import 'package:fitmom_guide/core/utils/dimensions.dart';
import 'package:flutter/material.dart';
import 'widget/cover_image.dart';
import 'widget/profile_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomLeft,
        children: [
          coverImage(),
          const Positioned(
            top: Dimensions.topProfile,
            child: ProfileHeader(),
          ),
        ],
      ),
    );
  }
}
