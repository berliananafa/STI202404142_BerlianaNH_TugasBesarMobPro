import 'package:flutter/material.dart';

// import halaman-halaman
import 'pages/beranda_page.dart';
import 'pages/tentang_page.dart';
import 'pages/tambah_page.dart';
import 'pages/peta_page.dart';
import 'pages/rekomedasi_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JELAJAH WISATA LOKAL',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // daftar halaman sesuai bottom nav
  final List<Widget> _pages = [
    BerandaPage(), // Home
    TentangPage(), // About
    TambahPage(), // Tambah Page
    PetaPage(), // Maps
    RekomendasiPage(), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            label: 'Saran',
          ),
        ],
      ),
    );
  }
}
