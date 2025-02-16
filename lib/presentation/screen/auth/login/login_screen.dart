import 'package:fitmom_guide/core/utils/my_color.dart';
import 'package:fitmom_guide/presentation/screen/auth/widget/forgot_button.dart';
import 'package:flutter/material.dart';
import 'package:fitmom_guide/core/utils/my_images.dart';
import 'package:fitmom_guide/data/services/auth/auth_service.dart';
import 'package:fitmom_guide/presentation/screen/home/home_screen.dart';
import 'package:fitmom_guide/presentation/screen/auth/registration/register_screen.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../components/gradient_background/gradient_background.dart';
import '../../../components/button/custom_button.dart';
import '../widget/auth_text_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final user = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Login gagal. Periksa email dan password.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: Dimensions.space30,
              ),
              Image.asset(MyImages.appLogoBanner),
              const SizedBox(height: Dimensions.space50),
              AuthTextInput(controller: emailController, hintText: "Email"),
              const SizedBox(height: Dimensions.space20),
              AuthTextInput(
                  controller: passwordController,
                  hintText: "Password",
                  isPassword: true),
              const SizedBox(height: Dimensions.space15),
              const ForgotButton(),
              const SizedBox(height: Dimensions.space30),
              CustomButton(
                text: "Masuk",
                onPressed: _login,
              ),
              const SizedBox(height: Dimensions.space20),
              CustomButton(
                text: "Daftar",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                color: Colors.white,
                textColor: MyColor.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
