import 'package:flutter/material.dart';

class ImageFrame extends StatelessWidget {
  final String imagePath;
  final double screenWidth;

  const ImageFrame(
      {super.key, required this.imagePath, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.35,
      height: screenWidth * 0.50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.pinkAccent, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: imagePath.startsWith('http')
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey));
                },
              )
            : Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}
