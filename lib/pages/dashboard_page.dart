import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/produk.dart';

// Halaman Dashboard SmartKasir
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _kategoriTerpilih = 0;

  final List<String> _kategoriList = ['Semua', 'Makanan', 'Minuman', 'Snack'];

  // Format harga ke mata uang Rupiah
  String _formatRupiah(double harga) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(harga);
  }

  @override
  Widget build(BuildContext context) {
    // Filter produk berdasarkan kategori yang dipilih
    final listTampil = _kategoriTerpilih == 0
        ? daftarProdukDummy
        : daftarProdukDummy
              .where((p) => p.kategori == _kategoriList[_kategoriTerpilih])
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartKasir'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner ringkasan toko
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang di SmartKasir!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola produk dan transaksi toko Anda dengan mudah.',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 12),
                Text(
                  'PROMO 20%',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Kategori Produk',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),

          // Filter kategori
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _kategoriList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_kategoriList[index]),
                    selected: _kategoriTerpilih == index,
                    onSelected: (selected) {
                      setState(() {
                        _kategoriTerpilih = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              'Katalog Produk',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),

          // Grid katalog produk 2 kolom
          Expanded(
            child: listTampil.isEmpty
                ? const Center(
                    child: Text('Tidak ada produk pada kategori ini'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.90,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: listTampil.length,
                    itemBuilder: (context, index) {
                      final produk = listTampil[index];

                      // Status stok produk
                      Color warnaStok;
                      String statusStok;

                      if (produk.stok == 0) {
                        warnaStok = Colors.red;
                        statusStok = 'Habis';
                      } else if (produk.stok <= 5) {
                        warnaStok = Colors.orange;
                        statusStok = 'Menipis';
                      } else {
                        warnaStok = Colors.green;
                        statusStok = 'Aman';
                      }

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto dan badge promo
                            Stack(
                              children: [
                                Image.network(
                                  produk.gambarUrl,
                                  height: 125,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 125,
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 125,
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 36,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                if (produk.diskonPersen > 0)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'PROMO ${produk.diskonPersen}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produk.nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatRupiah(produk.harga),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Badge status stok
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: warnaStok.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      'Stok ${produk.stok} - $statusStok',
                                      style: TextStyle(
                                        color: warnaStok,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Tombol tambah produk
                                  SizedBox(
                                    width: double.infinity,
                                    height: 30,
                                    child: ElevatedButton(
                                      onPressed: produk.stok == 0
                                          ? null
                                          : () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${produk.nama} ditambahkan',
                                                  ),
                                                ),
                                              );
                                            },
                                      child: const Text(
                                        '+ Tambah',
                                        style: TextStyle(fontSize: 11),
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
    );
  }
}
