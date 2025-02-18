import 'package:fitmom_guide/presentation/screen/auth/forgot_password/forgot_password.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/style.dart';

class ForgotButton extends StatelessWidget {
  const ForgotButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: const Text(
          "Lupa Password?",
          style: boldMediumLarge,
        ),
      ),
    );
  }
}
