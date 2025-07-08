import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_images.dart';

class CoverImageWidget extends StatefulWidget {
  final bool showAdminControls;

  const CoverImageWidget({super.key, this.showAdminControls = false});

  @override
  State<CoverImageWidget> createState() => _CoverImageWidgetState();
}

class _CoverImageWidgetState extends State<CoverImageWidget> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _coverImagePath = 'cover_images/app_cover.jpg';
  File? _localImage;
  bool _isUploading = false;
  bool _firebaseImageExists = false;

  @override
  void initState() {
    super.initState();
    _checkIfImageExists();
  }

  Future<void> _checkIfImageExists() async {
    try {
      final ref = _storage.ref().child(_coverImagePath);
      // This will throw an error if the file doesn't exist
      await ref.getDownloadURL();
      setState(() => _firebaseImageExists = true);
    } catch (e) {
      setState(() => _firebaseImageExists = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildCoverImage(),
        if (widget.showAdminControls) _buildAdminControls(),
      ],
    );
  }

  Widget _buildCoverImage() {
    return FutureBuilder<File?>(
      future: _getCoverImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPlaceholder();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _buildFallbackImage();
        }

        return Container(
          color: Colors.grey,
          child: Image.file(
            snapshot.data!,
            width: double.infinity,
            height: Dimensions.coverHeight,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey,
      width: double.infinity,
      height: Dimensions.coverHeight,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey,
      child: Image.asset(
        MyImages.coverBg,
        width: double.infinity,
        height: Dimensions.coverHeight,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildAdminControls() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Row(
        children: [
          if (_isUploading)
            const CircularProgressIndicator()
          else ...[
            _buildUploadButton(),
            const SizedBox(width: 10),
            if (_firebaseImageExists) _buildDeleteButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return FloatingActionButton(
      mini: true,
      onPressed: _uploadCoverImage,
      child: const Icon(Icons.add_photo_alternate),
    );
  }

  Widget _buildDeleteButton() {
    return FloatingActionButton(
      mini: true,
      onPressed: _deleteCoverImage,
      backgroundColor: Colors.red,
      child: const Icon(Icons.delete),
    );
  }

  Future<File?> _getCoverImage() async {
    if (_localImage != null) return _localImage;

    try {
      if (!_firebaseImageExists) return null;

      final ref = _storage.ref().child(_coverImagePath);
      final url = await ref.getDownloadURL();
      return await DefaultCacheManager().getSingleFile(url);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        setState(() => _firebaseImageExists = false);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _uploadCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      _localImage = File(pickedFile.path);

      try {
        final ref = _storage.ref().child(_coverImagePath);
        await ref.putFile(_localImage!);
        
        await DefaultCacheManager().emptyCache();
        setState(() => _firebaseImageExists = true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cover image updated successfully')),
          );
        }
      } on FirebaseException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Firebase error: ${e.code}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  Future<void> _deleteCoverImage() async {
    setState(() => _isUploading = true);
    try {
      final ref = _storage.ref().child(_coverImagePath);
      await ref.delete();
      
      await DefaultCacheManager().emptyCache();
      _localImage = null;
      setState(() => _firebaseImageExists = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cover image deleted successfully')),
        );
      }
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        setState(() => _firebaseImageExists = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${e.code}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}