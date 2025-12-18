// lib/pages/detail_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/destinasi.dart';
import 'peta_page.dart';

class DetailPage extends StatelessWidget {
  final Destinasi destinasi;
  const DetailPage({super.key, required this.destinasi});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF26B7A0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1F2D3D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Wisata',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2D3D),
          ),
        ),
      ),

      body: Container(
        height: double.infinity, // ⭐ PENTING: biar gradasi full
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBEEBFA), Color(0xFFDDF3E4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NAMA
                      Text(
                        destinasi.nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // FOTO
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child:
                            destinasi.fotoPath != null &&
                                destinasi.fotoPath!.isNotEmpty
                            ? Image.file(
                                File(destinasi.fotoPath!),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/placeholder.jpg',
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),

                      const SizedBox(height: 16),

                      // LOKASI
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: primary),
                          const SizedBox(width: 6),
                          Expanded(child: Text(destinasi.lokasi)),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // JAM BUKA (bold rapi)
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Jam buka: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: destinasi.jamBuka),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // DESKRIPSI
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(destinasi.deskripsi, textAlign: TextAlign.justify),

                      const SizedBox(height: 16),

                      // KOORDINAT
                      Text(
                        'Koordinat: ${destinasi.latitude}, ${destinasi.longitude}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // TOMBOL MAP (TETAP ADA)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PetaPage(
                                  latitude: destinasi.latitude,
                                  longitude: destinasi.longitude,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Tampilkan di Peta'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
