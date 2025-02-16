import 'dart:async';
import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:fitmom_guide/core/utils/my_images.dart';
import 'package:flutter/material.dart';
import 'package:fitmom_guide/presentation/screen/auth/login/login_screen.dart';

import '../../components/gradient_background/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [MyColor.primaryColor, MyColor.thirdColor],
            ),
          ),
          child: Center(
            child: Image.asset(MyImages.appLogo),
          ),
        ),
      ),
    );
  }
}
