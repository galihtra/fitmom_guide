import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? _selectedImage;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// **Memuat Data User dari Firestore**
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot userData =
        await _firestore.collection("users").doc(user.uid).get();

    if (userData.exists) {
      setState(() {
        nameController.text = userData["name"] ?? "";
        emailController.text = userData["email"] ?? "";
        phoneController.text = userData["phone"] ?? "";
        _profileImageUrl = userData["profileImage"];
      });
    }
  }

  /// **Memilih Foto Profil dari Galeri**
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// **Mengupload Foto ke Firebase Storage**
  Future<String?> _uploadImage(User user) async {
    if (_selectedImage == null) return _profileImageUrl;
    try {
      Reference ref = _storage.ref().child("profile_images/${user.uid}.jpg");
      UploadTask uploadTask = ref.putFile(_selectedImage!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// **Menyimpan Perubahan Profil ke Firestore**
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    User? user = _auth.currentUser;
    if (user == null) return;

    String? imageUrl = await _uploadImage(user);

    await _firestore.collection("users").doc(user.uid).update({
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
      "profileImage": imageUrl,
    });

    setState(() {
      _profileImageUrl = imageUrl;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// **Avatar Upload**
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null) as ImageProvider?,
                  child: _selectedImage == null && _profileImageUrl == null
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              /// **Nama**
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              /// **Email**
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              /// **No HP**
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "No HP",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              /// **Button Simpan**
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                      ),
                      child: const Text(
                        "Simpan Perubahan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
