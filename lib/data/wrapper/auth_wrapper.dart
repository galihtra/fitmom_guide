import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitmom_guide/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../presentation/screen/auth/login/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? const LoginScreen() : const DashboardScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
