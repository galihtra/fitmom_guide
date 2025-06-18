import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AccessDeniedDialog extends StatelessWidget {
  final String courseName;
  final String adminPhone;
  final VoidCallback? onCancel;

  const AccessDeniedDialog({
    super.key,
    required this.courseName,
    required this.adminPhone,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      title: Row(
        children: const [
          Icon(Icons.lock_outline, color: Colors.orange, size: 28),
          SizedBox(width: 8),
          Text(
            'Akses Dibatasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        'Program "$courseName" belum tersedia untukmu saat ini.\n\nSilakan hubungi admin untuk mendapatkan akses.',
        style: const TextStyle(height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: const Text('Nanti saja'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final encodedMessage = Uri.encodeComponent(
                'Halo admin, saya ingin mengakses program *$courseName* di FitMom Guide.');
            final url = 'https://wa.me/$adminPhone?text=$encodedMessage';
            Navigator.pop(context);
            if (await canLaunchUrl(Uri.parse(url))) {
              launchUrl(Uri.parse(url));
            }
          },
          icon: const Icon(Icons.chat),
          label: const Text('Hubungi Admin'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
