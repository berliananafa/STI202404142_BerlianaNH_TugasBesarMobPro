import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/destinasi.dart';
import 'tambah_page.dart';
import 'package:travel_wisata_lokal/pages/detail_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late Future<List<Destinasi>> _futureList;
  List<Destinasi> _allData = [];
  List<Destinasi> _filteredData = [];
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearch);
  }

  void _loadData() {
    _futureList = DatabaseHelper.instance.getAllDestinasi();
    _futureList.then((value) {
      setState(() {
        _allData = value;
        _filteredData = value;
      });
    });
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredData = _allData.where((d) {
        return d.nama.toLowerCase().contains(q) ||
            d.lokasi.toLowerCase().contains(q);
      }).toList();
    });
  }

  // ================= KONFIRMASI HAPUS =================
  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 36,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hapus wisata?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Data yang dihapus tidak dapat dikembalikan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= NOTIFIKASI BERHASIL =================
  Future<void> _showDeleteSuccess() async {
    showDialog(
      context: context,
      barrierDismissible: false, // biar ga bisa di-tap
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.check_circle_rounded,
              size: 72,
              color: Color(0xFF26B7A0),
            ),
            SizedBox(height: 16),
            Text(
              'Berhasil dihapus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Data wisata telah dihapus.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
    // ⏱️ AUTO TUTUP 1 DETIK
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF26B7A0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Daftar Wisata',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2D3D),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahPage()),
          ).then((_) => _loadData());
        },
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: 'Cari wisata...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: FutureBuilder<List<Destinasi>>(
                    future: _futureList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (_filteredData.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.map_outlined, size: 64),
                            SizedBox(height: 12),
                            Text('Wisata tidak ditemukan'),
                          ],
                        );
                      }

                      return ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (context, i) {
                          final d = _filteredData[i];
                          final isFav = _favoriteIds.contains(d.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child:
                                      d.fotoPath != null &&
                                          d.fotoPath!.isNotEmpty
                                      ? Image.file(
                                          File(d.fotoPath!),
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 64,
                                          height: 64,
                                          color: primary,
                                          child: const Icon(
                                            Icons.landscape,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              d.nama,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isFav
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFav
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isFav
                                                    ? _favoriteIds.remove(d.id)
                                                    : _favoriteIds.add(d.id!);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Text(d.lokasi),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _btn(Icons.edit, 'Edit', () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    TambahPage(edited: d),
                                              ),
                                            ).then((_) => _loadData());
                                          }),
                                          const SizedBox(width: 12),
                                          _btn(Icons.info, 'Detail', () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DetailPage(destinasi: d),
                                              ),
                                            );
                                          }),
                                          const SizedBox(width: 12),
                                          _btn(Icons.delete, 'Hapus', () async {
                                            final ok = await _confirmDelete();
                                            if (ok == true && d.id != null) {
                                              await DatabaseHelper.instance
                                                  .deleteDestinasi(d.id!);
                                              _loadData();
                                              _showDeleteSuccess();
                                            }
                                          }, color: Colors.red),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(
    IconData icon,
    String text,
    VoidCallback onTap, {
    Color color = const Color(0xFF1F2D3D),
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
