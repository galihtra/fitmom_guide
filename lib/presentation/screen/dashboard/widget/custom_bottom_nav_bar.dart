import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fitmom_guide/core/utils/my_images.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  Widget _buildNavIcon(String activeIcon, String inactiveIcon, int index) {
    return SvgPicture.asset(
      selectedIndex == index ? activeIcon : inactiveIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: Colors.white,
      selectedItemColor: MyColor.secondaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: _buildNavIcon(MyImages.homeActive, MyImages.home, 0),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(MyImages.profileActive, MyImages.profile, 1),
          label: '',
        ),
      ],
    );
  }
}
