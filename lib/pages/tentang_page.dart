import 'package:flutter/material.dart';
import '../main.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // ===== APP BAR (KONSISTEN DENGAN PAGE LAIN) =====
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2D3D)),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2D3D),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBEEBFA), Color(0xFFDDF3E4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 72, 20, 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.near_me_outlined,
                    size: 56,
                    color: Color(0xFF1F2D3D),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Halo!\n\n'
                    'Travel Wisata Lokal merupakan aplikasi untuk menjelajah wisata '
                    'yang dikembangkan oleh mahasiswa STMIK Widya Utama.\n\n'
                    'Aplikasi ini membantu pengguna menemukan destinasi wisata, '
                    'merencanakan perjalanan, serta mengenal potensi wisata lokal '
                    'di berbagai daerah Indonesia.\n\n'
                    'Salam kami,\n'
                    'Tim Pengembang',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF1F2D3D),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
