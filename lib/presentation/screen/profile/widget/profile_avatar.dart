import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitmom_guide/core/utils/dimensions.dart';
import 'package:fitmom_guide/core/utils/my_images.dart';

class ProfileAvatar extends StatelessWidget {
  final bool isLoading;
  final String? profileImageUrl;

  const ProfileAvatar({
    Key? key,
    required this.isLoading,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CircleAvatar(
            radius: Dimensions.profileRadiusSmalll,
            backgroundColor: Colors.grey,
            child: CircularProgressIndicator(color: Colors.white),
          )
        : CircleAvatar(
            radius: Dimensions.profileRadiusSmalll,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
            child: profileImageUrl == null
                ? SvgPicture.asset(MyImages.profile, fit: BoxFit.cover)
                : null,
          );
  }
}
