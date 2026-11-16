// Model data representasi entitas Karyawan pada SmartKasir
class Karyawan {
  // ID unik karyawan (auto increment di SQLite, null saat staf baru belum disimpan)
  final int? id;
  // Nama lengkap atau nama panggilan staf kasir
  final String namaKaryawan;
  // PIN pengaman 4 digit angka untuk otentikasi giliran shift kasir
  final String pin;
  // Peran tanggung jawab kerja: 'Kasir', 'Admin', atau 'Manajer'
  final String peran;

  const Karyawan({
    this.id,
    required this.namaKaryawan,
    required this.pin,
    required this.peran,
  });

  // Dart Object -> Map (untuk disimpan ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_karyawan': namaKaryawan,
      'pin': pin,
      'peran': peran,
    };
  }

  // Map -> Dart Object (hasil kueri SQLite)
  factory Karyawan.fromMap(Map<String, dynamic> map) {
    return Karyawan(
      id: map['id'] as int?,
      namaKaryawan: map['nama_karyawan'] as String,
      pin: map['pin'] as String,
      peran: map['peran'] as String,
    );
  }
}
