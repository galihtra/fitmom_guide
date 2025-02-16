import 'package:flutter/material.dart';

import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final Color borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = MyColor.buttonBgColor,
    this.textColor = Colors.white,
    this.borderColor = MyColor.buttonBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: Text(
        text,
        style: textButtonSecondary,
      ),
    );
  }
}
