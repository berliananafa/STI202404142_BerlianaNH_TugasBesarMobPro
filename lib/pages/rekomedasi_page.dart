import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../db/database_helper.dart';
import '../models/destinasi.dart';
import '../main.dart';
import 'detail_page.dart';

class RekomendasiPage extends StatefulWidget {
  const RekomendasiPage({super.key});

  @override
  State<RekomendasiPage> createState() => _RekomendasiPageState();
}

class _RekomendasiPageState extends State<RekomendasiPage> {
  bool _loading = true;
  String? _error;

  int _estimasiMenit(double jarakKm) {
    final menit = (jarakKm / 30) * 60;
    return menit < 1 ? 1 : menit.round();
  }

  List<_RekomendasiItem> _rekomendasi = [];

  @override
  void initState() {
    super.initState();
    _loadRekomendasi();
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Location service tidak aktif';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _loadRekomendasi() async {
    try {
      final userPos = await _getUserLocation();
      final data = await DatabaseHelper.instance.getAllDestinasi();

      final List<_RekomendasiItem> temp = [];

      for (final d in data) {
        final distance = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          d.latitude,
          d.longitude,
        );

        if (distance <= 10000) {
          temp.add(_RekomendasiItem(destinasi: d, distanceKm: distance / 1000));
        }
      }

      temp.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      setState(() {
        _rekomendasi = temp;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainPage()),
            );
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.explore, color: Color(0xFF1F2D3D)),
            SizedBox(width: 6),
            Text(
              'Rekomendasi Wisata',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2D3D),
              ),
            ),
          ],
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBEEBFA), Color(0xFFDDF3E4)],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _rekomendasi.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada wisata terdekat\n(≤ 10 KM)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Rekomendasi wisata jarak ≤ 10 km dari lokasi Anda',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF455A64),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          MediaQuery.of(context).padding.bottom + 16,
                        ),
                        itemCount: _rekomendasi.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.60, // 🔧 DISUAIKAN DIKIT
                            ),
                        itemBuilder: (context, i) {
                          final item = _rekomendasi[i];
                          final d = item.destinasi;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child:
                                      d.fotoPath != null &&
                                          d.fotoPath!.isNotEmpty
                                      ? Image.file(
                                          File(d.fotoPath!),
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 120,
                                          color: Colors.teal.shade200,
                                          child: const Center(
                                            child: Icon(
                                              Icons.landscape,
                                              size: 48,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.nama,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        d.lokasi,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      /// JARAK + WAKTU (1 BARIS)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Color(0xFF26B7A0),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${item.distanceKm.toStringAsFixed(2)} km • ${_estimasiMenit(item.distanceKm)} menit',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF26B7A0),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      /// DARI LOKASI ANDA
                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.my_location,
                                            size: 14,
                                            color: Color(0xFF26B7A0),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'dari lokasi Anda',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF26B7A0),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 30,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DetailPage(destinasi: d),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF26B7A0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            'Lihat',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RekomendasiItem {
  final Destinasi destinasi;
  final double distanceKm;

  _RekomendasiItem({required this.destinasi, required this.distanceKm});
}
