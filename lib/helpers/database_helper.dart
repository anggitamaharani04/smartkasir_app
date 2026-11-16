// Mengimpor pustaka deteksi platform Flutter (untuk memeriksa peramban web kIsWeb)
import 'package:flutter/foundation.dart';
// Mengimpor pustaka inti SQLite untuk Flutter
import 'package:sqflite/sqflite.dart';
// Mengimpor pustaka penggabungan path direktori berkas lokal
import 'package:path/path.dart';
// Mengimpor implementasi SQLite FFI khusus peramban Web Google Chrome
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Mengimpor model data produk dan karyawan
import '../models/produk.dart';
import '../models/karyawan.dart';

// Kelas pengelola koneksi dan operasi basis data SQLite lokal SmartKasir
class DatabaseHelper {
  // --- 1. DESIGN PATTERN SINGLETON ---
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // --- 2. GETTER DATABASE ASINKRON ---
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartkasir.db');
    return _database!;
  }

  // --- 3. INISIALISASI BASIS DATA (DUAL-PLATFORM CHROME & ANDROID) ---
  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        filePath,
        version: 2, // Dinaikkan dari 1 ke 2 (tambah tabel karyawan)
        onCreate: _createDB,
        onUpgrade: _onUpgradeDB,
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  // --- 4. DDL: PEMBUATAN TABEL (UNTUK DATABASE BARU) ---
  Future _createDB(Database db, int version) async {
    // 1. Tabel produk
    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_produk TEXT UNIQUE,
        nama_produk TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga_beli REAL NOT NULL,
        harga_jual REAL NOT NULL,
        stok INTEGER NOT NULL,
        gambar_path TEXT,
        diskon_persen INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // Seeding data awal produk
    for (final produk in produkAwalSQLite) {
      await db.insert('produk', produk.toMap());
    }

    // 2. Tabel karyawan
    await db.execute('''
      CREATE TABLE karyawan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_karyawan TEXT NOT NULL,
        pin TEXT NOT NULL,
        peran TEXT NOT NULL
      )
    ''');

    // Seeding staf awal
    await _seedKaryawan(db);
  }

  // --- 5. MIGRASI: DATABASE LAMA (VERSI 1) -> VERSI 2 ---
  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS karyawan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_karyawan TEXT NOT NULL,
          pin TEXT NOT NULL,
          peran TEXT NOT NULL
        )
      ''');
      await _seedKaryawan(db);
    }
  }

  // Helper: memasukkan 2 staf awal
  Future<void> _seedKaryawan(Database db) async {
    await db.rawInsert('''
      INSERT INTO karyawan (nama_karyawan, pin, peran)
      VALUES ('Ahmad Kasir', '1234', 'Kasir')
    ''');
    await db.rawInsert('''
      INSERT INTO karyawan (nama_karyawan, pin, peran)
      VALUES ('Siti Supervisor', '8888', 'Manajer')
    ''');
  }

  // ==========================================
  // CRUD TABEL KARYAWAN
  // ==========================================

  // CREATE
  Future<int> insertKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return await db.insert('karyawan', karyawan.toMap());
  }

  // READ
  Future<List<Karyawan>> getAllKaryawan() async {
    final db = await instance.database;
    final result = await db.query('karyawan', orderBy: 'id ASC');
    return result.map((json) => Karyawan.fromMap(json)).toList();
  }

  // UPDATE
  Future<int> updateKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return await db.update(
      'karyawan',
      karyawan.toMap(),
      where: 'id = ?',
      whereArgs: [karyawan.id],
    );
  }

  // DELETE
  Future<int> deleteKaryawan(int id) async {
    final db = await instance.database;
    return await db.delete('karyawan', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // CRUD TABEL PRODUK (DARI MINGGU 11, TIDAK BERUBAH)
  // ==========================================

  Future<int> insertProduk(Produk produk) async {
    final db = await instance.database;
    final id = await db.insert(
      'produk',
      produk.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<Produk>> getAllProduk() async {
    final db = await instance.database;
    final result = await db.query('produk', orderBy: 'harga_jual ASC');
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<List<Produk>> getProdukByKategori(String kategori) async {
    final db = await instance.database;
    if (kategori == 'Semua') {
      return await getAllProduk();
    }
    final result = await db.query(
      'produk',
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'id DESC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<List<Produk>> searchProduk(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'produk',
      where: 'nama_produk LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<int> updateProduk(Produk produk) async {
    final db = await instance.database;
    return await db.update(
      'produk',
      produk.toMap(),
      where: 'id = ?',
      whereArgs: [produk.id],
    );
  }

  Future<int> deleteProduk(int id) async {
    final db = await instance.database;
    return await db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }
}
