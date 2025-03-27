import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/login/login_screen.dart';

class DeleteAccountWidget extends StatelessWidget {
  const DeleteAccountWidget({super.key});

  // Fungsi untuk reauthenticate dan menghapus akun
  Future<void> _reauthenticateAndDelete(BuildContext context) async {
    try {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      User? user = firebaseAuth.currentUser;

      if (user == null) {
        _showError(context, "Tidak ada pengguna yang sedang login.");
        return;
      }

      // Ambil metode login yang digunakan oleh user
      final providerData = user.providerData.first;

      // Periksa jenis provider dan lakukan reauth
      if (providerData.providerId == EmailAuthProvider.PROVIDER_ID) {
        // Contoh reauthentication dengan email dan password (harus meminta password lagi)
        final email = user.email ?? '';
        final passwordController = TextEditingController();

        // Dialog meminta user memasukkan password lagi
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Masukkan Password"),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Masukkan password"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Lanjut"),
              ),
            ],
          ),
        );

        if (passwordController.text.isNotEmpty) {
          final authCredential = EmailAuthProvider.credential(
            email: email,
            password: passwordController.text,
          );
          await user.reauthenticateWithCredential(authCredential);
        } else {
          _showError(context, "Password tidak boleh kosong.");
          return;
        }
      } else if (providerData.providerId == GoogleAuthProvider.PROVIDER_ID) {
        await user.reauthenticateWithProvider(GoogleAuthProvider());
      } else if (providerData.providerId == AppleAuthProvider.PROVIDER_ID) {
        await user.reauthenticateWithProvider(AppleAuthProvider());
      } else {
        _showError(
            context, "Metode login tidak dikenali. Silakan login ulang.");
        return;
      }

      // Jika reauth berhasil, hapus akun
      await user.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Akun Anda telah berhasil dihapus."),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showError(context,
            "Autentikasi Anda sudah lama. Silakan login ulang lalu coba lagi.");
      } else {
        _showError(context, "Kesalahan autentikasi: ${e.message}");
      }
    } catch (e) {
      _showError(context, "Kesalahan tidak terduga: $e");
    }
  }

  // Menampilkan dialog kesalahan
  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kesalahan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDeleteAccountModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.delete_forever, color: Colors.redAccent, size: 30),
            const SizedBox(height: 5),
            const Text(
              "Hapus Akun",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Data Anda akan dihapus secara permanen dan tidak bisa dikembalikan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menampilkan modal konfirmasi penghapusan akun
  void _showDeleteAccountModal(BuildContext context) {
    bool _isChecked = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Akun",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Apakah Anda yakin ingin menghapus akun Anda? Tindakan ini tidak dapat dibatalkan.",
                style: TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Harap konfirmasi tindakan ini dengan mencentang kotak di bawah.",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Saya memahami bahwa data saya akan dihapus secara permanen.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isChecked ? Colors.redAccent : Colors.grey,
              ),
              onPressed: _isChecked
                  ? () {
                      Navigator.of(context).pop();
                      _reauthenticateAndDelete(context);
                    }
                  : null,
              child: const Text(
                "Hapus Akun",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
