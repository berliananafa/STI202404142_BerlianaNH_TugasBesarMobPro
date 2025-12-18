import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/destinasi.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'destinasi.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE destinasi(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT,
      lokasi TEXT,
      lat REAL,
      lng REAL,
      deskripsi TEXT,
      fotoPath TEXT,
      jamBuka TEXT
    )
  ''');
  }

  /// Ambil semua data destinasi
  Future<List<Destinasi>> getAllDestinasi() async {
    final db = await database;
    final maps = await db.query('destinasi', orderBy: 'id DESC');

    return maps.map((e) => Destinasi.fromMap(e)).toList();
  }

  /// Tambah destinasi
  Future<int> addDestinasi(Destinasi d) async {
    final db = await database;
    return await db.insert('destinasi', d.toMap());
  }

  /// Update destinasi
  Future<int> updateDestinasi(Destinasi d) async {
    final db = await database;
    return await db.update(
      'destinasi',
      d.toMap(),
      where: 'id = ?',
      whereArgs: [d.id],
    );
  }

  /// Hapus destinasi
  Future<int> deleteDestinasi(int id) async {
    final db = await database;
    return await db.delete('destinasi', where: 'id = ?', whereArgs: [id]);
  }
}
