import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitmom_guide/presentation/components/gradient_background/gradient_background.dart';
import 'package:fitmom_guide/presentation/screen/auth/widget/auth_text_input.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../components/button/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void forgotPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("Masukkan email Anda");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessage("Email reset password telah dikirim!", isSuccess: true);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Terjadi kesalahan. Coba lagi.";

      if (e.code == 'user-not-found') {
        errorMessage = "Email tidak terdaftar.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Format email tidak valid.";
      }

      _showMessage(errorMessage);
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: Dimensions.space50),
                  AuthTextInput(
                    controller: emailController,
                    hintText: "Email",
                  ),
                  const SizedBox(height: Dimensions.space20),
                  CustomButton(
                    text: "Kirim",
                    onPressed: forgotPassword,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
