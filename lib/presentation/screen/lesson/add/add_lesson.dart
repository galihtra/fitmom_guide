import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../data/model/lesson/lesson.dart';
import '../../../../data/services/lesson/lesson_service.dart';

class AddLessonScreen extends StatefulWidget {
  final String courseId;

  AddLessonScreen({required this.courseId});

  @override
  _AddLessonScreenState createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final LessonService _lessonService = LessonService();

  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('lesson_images/$fileName');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  void _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    String imageUrl = '';
    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
    }

    final lesson = Lesson(
      id: '',
      idCourse: widget.courseId,
      name: _nameController.text,
      description: _descriptionController.text,
      image: imageUrl,
      urlVideo: _videoUrlController.text,
      isCompleted: false,
      commentar: '',
      ulasanPengguna: '',
      rating: 0.0,
    );

    await _lessonService.addLesson(lesson);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Lesson')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Lesson Name'),
                  validator: (value) => value!.isEmpty ? 'Enter lesson name' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Enter description' : null,
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: _pickImage,
                  child: _image != null
                      ? Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover)
                      : Container(
                          width: 150,
                          height: 150,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
                        ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _videoUrlController,
                  decoration: InputDecoration(labelText: 'Video URL'),
                  validator: (value) => value!.isEmpty ? 'Enter video URL' : null,
                ),
                SizedBox(height: 20),
                _isUploading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveLesson,
                        child: Text('Save Lesson'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
