// lib/pages/tambah_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';
import '../models/destinasi.dart';
import 'map_picker_page.dart';
import '../main.dart';

class TambahPage extends StatefulWidget {
  final Destinasi? edited;
  const TambahPage({super.key, this.edited});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final _form = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _lokasi = TextEditingController();
  final _des = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  TimeOfDay? _jam;
  String? _fotoPath;

  final _picker = ImagePicker();
  final _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    if (widget.edited != null) {
      final d = widget.edited!;
      _nama.text = d.nama;
      _lokasi.text = d.lokasi;
      _des.text = d.deskripsi;
      _lat.text = d.latitude.toString();
      _lng.text = d.longitude.toString();
      _fotoPath = d.fotoPath;
      _jam = _parseJam(d.jamBuka);
    }
  }

  TimeOfDay? _parseJam(String s) {
    try {
      final p = s.split(':');
      return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    final saved = await _saveFilePermanently(File(picked.path));
    setState(() => _fotoPath = saved.path);
  }

  Future<File> _saveFilePermanently(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${dir.path}/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    final name = p.basename(file.path);
    final newPath =
        '${imageDir.path}/${DateTime.now().millisecondsSinceEpoch}_$name';
    return file.copy(newPath);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _jam ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _jam = t);
  }

  Future<void> _pickFromMap() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerPage()),
    );
    if (res is Map<String, double>) {
      _lat.text = res['lat'].toString();
      _lng.text = res['lng'].toString();
    }
  }

  String? _validateLatLng(String? v, bool isLat) {
    if (v == null || v.isEmpty) return 'Wajib diisi';
    final d = double.tryParse(v);
    if (d == null) return 'Harus angka';
    if (isLat && (d < -90 || d > 90)) return 'Latitude -90..90';
    if (!isLat && (d < -180 || d > 180)) return 'Longitude -180..180';
    return null;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_jam == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pilih jam buka')));
      return;
    }

    final jam =
        '${_jam!.hour.toString().padLeft(2, '0')}:${_jam!.minute.toString().padLeft(2, '0')}';

    final data = Destinasi(
      id: widget.edited?.id,
      nama: _nama.text.trim(),
      lokasi: _lokasi.text.trim(),
      deskripsi: _des.text.trim(),
      fotoPath: _fotoPath,
      jamBuka: jam,
      latitude: double.parse(_lat.text),
      longitude: double.parse(_lng.text),
    );

    widget.edited == null
        ? await _db.addDestinasi(data)
        : await _db.updateDestinasi(data);

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.celebration_rounded, size: 72, color: Color(0xFF26B7A0)),
            SizedBox(height: 16),
            Text(
              'Yeay! 🎉',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Wisata tujuanmu berhasil disimpan.\n'
              'Cek daftar wisatamu ya ✨',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(); // tutup dialog

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainPage()),
                (route) => false,
              );
            },

            child: const Text('Oke'),
          ),
        ],
      ),
    );
  }

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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainPage()),
            );
          },
        ),

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.place_rounded, color: Color(0xFF26B7A0)),
            const SizedBox(width: 8),
            Text(
              widget.edited == null ? 'Tambah Wisata' : 'Edit Wisata',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2D3D),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: _save,
        child: const Icon(Icons.save_outlined),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F5F7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFD0D8DE),
                              ),
                            ),
                            child: _fotoPath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      File(_fotoPath!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 40,
                                          color: Color(0xFF7A8A96),
                                        ),
                                        SizedBox(height: 8),
                                        Text('Tambah Gambar'),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _field(_nama, 'Nama Destinasi'),
                        _field(_lokasi, 'Alamat / Lokasi'),
                        _field(_des, 'Deskripsi', maxLines: 3),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                _lat,
                                'Latitude',
                                validator: (v) => _validateLatLng(v, true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _field(
                                _lng,
                                'Longitude',
                                validator: (v) => _validateLatLng(v, false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickTime,
                                icon: const Icon(
                                  Icons.access_time,
                                  color: primary,
                                ),
                                label: Text(
                                  _jam == null
                                      ? 'Jam Buka'
                                      : _jam!.format(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickFromMap,
                                icon: const Icon(
                                  Icons.map_outlined,
                                  color: primary,
                                ),
                                label: const Text('Pilih Peta'),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _field(
    TextEditingController c,
    String label, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: const Color(0xFFF6F8FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
