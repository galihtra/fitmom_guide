import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../data/services/testimonial/testimonial_service.dart';

class AddTestimonialScreen extends StatefulWidget {
  const AddTestimonialScreen({super.key});

  @override
  State<AddTestimonialScreen> createState() => _AddTestimonialScreenState();
}

class _AddTestimonialScreenState extends State<AddTestimonialScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _beforeImage;
  File? _afterImage;
  final TestimonialService _testimonialService = TestimonialService();

  Future<void> _pickImage(bool isBefore) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isBefore) {
          _beforeImage = File(pickedFile.path);
        } else {
          _afterImage = File(pickedFile.path);
        }
      });
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan klik luar
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(color: Colors.pinkAccent),
                SizedBox(height: 20),
                Text(
                  "Menyimpan testimonial...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addTestimonial() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _beforeImage == null ||
        _afterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    // Tampilkan dialog loading
    _showLoadingDialog();

    try {
      await _testimonialService.addTestimonial({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'before': _beforeImage!.path,
        'after': _afterImage!.path,
      });

      Navigator.pop(context); // Tutup dialog loading
      Navigator.pop(context); // Kembali ke halaman sebelumnya

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Testimonial berhasil ditambahkan')),
      );
    } catch (e) {
      Navigator.pop(context); // Tutup dialog loading jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan testimonial: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Tambah Testimonial"),
          backgroundColor: Colors.pinkAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      _beforeImage == null
                          ? const Icon(Icons.image,
                              size: 80, color: Colors.grey)
                          : Image.file(_beforeImage!, width: 100, height: 100),
                      ElevatedButton(
                        onPressed: () => _pickImage(true),
                        child: const Text("Pilih Before"),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _afterImage == null
                          ? const Icon(Icons.image,
                              size: 80, color: Colors.grey)
                          : Image.file(_afterImage!, width: 100, height: 100),
                      ElevatedButton(
                        onPressed: () => _pickImage(false),
                        child: const Text("Pilih After"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTestimonial,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent),
                child: const Text("Tambahkan Testimonial",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
