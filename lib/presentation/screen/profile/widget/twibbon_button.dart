import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TwibbonCardWidget extends StatelessWidget {
  const TwibbonCardWidget({super.key});

  final String _twibbonUrl =
      'https://www.twibbonize.com/strongcore'; // Ganti URL sesuai kebutuhan

  Future<void> _launchTwibbon() async {
    final Uri url = Uri.parse(_twibbonUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka $_twibbonUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _launchTwibbon,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.pinkAccent.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.camera_alt_outlined, color: Colors.pink),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Update Progress dengan Twibbon",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.pink),
          ],
        ),
      ),
    );
  }
}
