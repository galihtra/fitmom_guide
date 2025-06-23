import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactAdminWidget extends StatefulWidget {
  const ContactAdminWidget({super.key});

  @override
  State<ContactAdminWidget> createState() => _ContactAdminWidgetState();
}

class _ContactAdminWidgetState extends State<ContactAdminWidget> {
  String? _phoneNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestPhoneNumber();
  }

  Future<void> _fetchLatestPhoneNumber() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('whatsapp_admin')
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _phoneNumber = snapshot.docs.first['number'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _phoneNumber = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching WA number: $e");
      setState(() {
        _phoneNumber = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _openWhatsApp() async {
    if (_phoneNumber == null) return;

    // Konversi 08xxx -> 62xxx
    String formattedNumber = _phoneNumber!;
    if (formattedNumber.startsWith('08')) {
      formattedNumber = '62${formattedNumber.substring(1)}';
    }

    // Hilangkan spasi atau simbol yang tidak perlu
    formattedNumber = formattedNumber.replaceAll(RegExp(r'\s+|-'), '');

    final url = "https://wa.me/$formattedNumber";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Gagal membuka WhatsApp untuk $formattedNumber");
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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _phoneNumber == null
              ? const Text(
                  "Nomor WhatsApp Admin belum tersedia.",
                  style: TextStyle(fontSize: 16),
                )
              : Column(
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
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
                              FaIcon(FontAwesomeIcons.whatsapp,
                                  color: Colors.white),
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
