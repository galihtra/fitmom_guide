import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka link WhatsApp

class ContactAdminWidget extends StatelessWidget {
  const ContactAdminWidget({super.key});

  void _openWhatsApp() async {
    const phoneNumber = "6287738479403"; // Nomor WA tujuan
    final url = "https://wa.me/$phoneNumber"; // Link WA dengan nomor langsung

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication); // Buka aplikasi eksternal (WA)
    } else {
      debugPrint("Failed to open WhatsApp"); // Handling jika gagal membuka
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Hubungi Admin",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Jika ada pertanyaan atau membutuhkan bantuan, Anda bisa langsung menghubungi Admin melalui WhatsApp.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Center(
            child: InkWell(
              onTap: _openWhatsApp,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Chat Admin di WhatsApp",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
