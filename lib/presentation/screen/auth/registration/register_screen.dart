import 'package:fitmom_guide/presentation/components/gradient_background/gradient_background.dart';
import 'package:fitmom_guide/presentation/screen/auth/widget/auth_text_input.dart';
import 'package:fitmom_guide/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../components/button/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "birthdate": birthdateController.text,
        "isAdmin": false,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registrasi gagal: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: Dimensions.space50),
                AuthTextInput(
                  controller: nameController,
                  hintText: "Nama Lengkap",
                ),
                const SizedBox(height: Dimensions.space20),
                AuthTextInput(
                  controller: emailController,
                  hintText: "Email",
                ),
                const SizedBox(height: Dimensions.space20),
                AuthTextInput(
                  controller: passwordController,
                  hintText: "Password",
                  isPassword: true,
                ),
                const SizedBox(height: Dimensions.space20),
                AuthTextInput(
                  controller: phoneController,
                  hintText: "No HP",
                ),
                const SizedBox(height: Dimensions.space20),
                AuthTextInput(
                  controller: birthdateController,
                  hintText: "Tanggal Lahir",
                  isDatePicker: true,
                ),
                const SizedBox(height: Dimensions.space30),
                CustomButton(
                  text: "Daftar",
                  onPressed: register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
