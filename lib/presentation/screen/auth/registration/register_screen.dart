import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fitmom_guide/presentation/components/gradient_background/gradient_background.dart';
import 'package:fitmom_guide/presentation/screen/auth/widget/auth_text_input.dart';
import 'package:fitmom_guide/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:image_picker/image_picker.dart';
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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(User user) async {
    if (_selectedImage == null) return null;
    try {
      Reference ref = _storage.ref().child("profile_images/${user.uid}.jpg");
      UploadTask uploadTask = ref.putFile(_selectedImage!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  void register() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String? profileImageUrl = await _uploadImage(userCredential.user!);

      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "birthdate": birthdateController.text,
        "profileImage": profileImageUrl,
        "isAdmin": false,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registrasi gagal: ${e.toString()}")),
      );
    }

    setState(() => _isLoading = false);
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

                  /// **Avatar Upload**
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: Dimensions.space20),

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

                  _isLoading
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: "Daftar",
                          onPressed: register,
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
