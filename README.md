# Aplikasi Travel Wisata Lokal - STMIK Widya Utama

Aplikasi "Travel Wisata Lokal" platform berbasis Flutter untuk menjelajah, merencanakan perjalanan, dan mengelola daftar destinasi wisata lokal dengan integrasi peta.

![Logo](https://static.vecteezy.com/system/resources/previews/022/036/061/non_2x/travel-logo-design-modern-logo-free-vector.jpg)

### Identitas Kelompok
* *Ketua:* Berliana Nafarita H - STI202404142
* *Anggota:* - Ikvina .H.N.(STI202303738),Yeni Setiyawati (STI202303650), Ayu Safitri (STI202303752), & Ngasiyatun K.H (STI202303754)

### 1. Fitur Utama

- "*CRUD SQLite:* Menambah, melihat, mengedit, dan menghapus destinasi wisata." *Detail Wisata:* Menampilkan informasi lengkap satu destinasi termasuk tampilan peta kecil koordinat lokasi.
- *Integrasi Google Maps:* Menampilkan marker lokasi wisata
- *Input Interaktif:* Menggunakan DatePicker dan TimePicker untuk jam operasional.
- *Navigasi:* Menggunakan Bottom Navigation Bar dengan menu Beranda, Tambah, dan Peta.

### 2. Paket (Dependencies) yang Digunakan
Sesuai kebutuhan teknis, aplikasi ini menggunakan:
* `sqflite`: Untuk penyimpanan data CRUD secara permanen.
* `Maps_flutter`: Untuk integrasi dan tampilan peta lokasi.
* `image_picker`: Untuk mengambil atau memilih foto destinasi wisata.
* `path_provider`: akses direktori file
* google_fonts atau paket UI lainnya yang relevan.


### 3. Skema Database SQLite (Kriteria No. 2 & 6)
Struktur tabel destinasi yang digunakan dalam aplikasi:

| Nama Kolom | Tipe Data | Deskripsi |
| :--- | :--- | :--- |
| *id* | INTEGER | Primary Key (Auto Increment) |
| *nama* | TEXT | Nama tempat wisata |
| *alamat* | TEXT | Alamat atau lokasi destinasi |
| *deskripsi* | TEXT | Penjelasan detail mengenai tempat wisata |
| *jam_buka* | TEXT | Jam operasional (Input dari TimePicker) |
| *latitude* | REAL | Titik koordinat lintang untuk Google Maps |
| *longitude* | REAL | Titik koordinat bujur untuk Google Maps |
| *gambar* | TEXT | Path atau lokasi file foto destinasi |


### 4. Running Tests

**a. Clone repository**
```bash
  `git clone <>
```
**b. Instal Library**
```bash
`flutter pub get` di terminal.
```
**c. Konfigurasi Maps:** Pastikan API Key Google Maps sudah terpasang di`AndroidManifest.xml`.

**d. Jalankan:** Hubungkan perangkat/emulator dan ketik
```bash
`flutter run`
```
**e. Build APK:** Gunakan perintah
```bash
`flutter build apk --release`
```


---
## 5. Screenshots

![Daftar Wisata]() 
![Detail Wisata]()
![Edit Wisata]()
![Tambah Wisata]() 
![Halaman Tentang]()
![Halaman Rekomendasi Wisata]()
![Maps]()
___

## Demo

link to demo
<>

### Documentation
* *Link APK:* <>
* *Link Video Presentasi:* <>
