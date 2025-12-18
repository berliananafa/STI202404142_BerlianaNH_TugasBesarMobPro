// lib/pages/home_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/destinasi.dart';
import 'tambah_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Destinasi> _list = [];
  String _search = "";
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Destinasi> data = await DatabaseHelper.instance.getAllDestinasi();

    // fungsi search lokal (karena tidak ada filter di database)
    if (_search.isNotEmpty) {
      data = data
          .where((d) => d.nama.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }

    setState(() => _list = data);
  }

  Future<void> _confirmDelete(Destinasi d) async {
    final bool? ok = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus?"),
        content: Text('Hapus "${d.nama}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (ok == true && d.id != null) {
      await DatabaseHelper.instance.deleteDestinasi(d.id!);
      await _loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Destinasi dihapus")));
    }
  }

  Widget _neumorphismCard(Destinasi d) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(6, 6),
            blurRadius: 12,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailPage(destinasi: d)),
            );
            _loadData();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: d.fotoPath != null && d.fotoPath!.isNotEmpty
                    ? Image.file(
                        File(d.fotoPath!),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/placeholder.jpg",
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.nama,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            d.lokasi,
                            style: TextStyle(color: Colors.cyan.shade700),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TambahPage(edited: d),
                            ),
                          );
                          _loadData();
                        } else if (v == 'hapus') {
                          _confirmDelete(d);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text("Edit")),
                        PopupMenuItem(value: 'hapus', child: Text("Hapus")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Travel Wisata Lokal",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan.shade700,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahPage()),
          );
          _loadData();
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama destinasi...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                _search = v;
                _loadData();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _list.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada destinasi",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (_, i) => _neumorphismCard(_list[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
