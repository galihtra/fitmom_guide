import 'package:flutter/material.dart';
import 'package:fitmom_guide/core/utils/my_color.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MyColor.primaryColor, MyColor.thirdColor],
        ),
      ),
      child: child,
    );
  }
}
