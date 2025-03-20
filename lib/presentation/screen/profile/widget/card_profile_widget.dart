import 'package:flutter/material.dart';

import '../edit/edit_profile_screen.dart';

class CardProfileWidget extends StatelessWidget {
  const CardProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
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
          children: const [
            Icon(Icons.privacy_tip_sharp, color: Colors.pink, size: 28),
            SizedBox(height: 6),
            Text(
              "Data Pribadi",
            ),
          ],
        ),
      ),
    );
  }
}
