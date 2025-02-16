import 'package:flutter/material.dart';

import '../../../data/services/auth/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) async {
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleLogout(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Logout", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
