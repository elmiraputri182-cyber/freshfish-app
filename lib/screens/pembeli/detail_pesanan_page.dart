import 'package:appfreshfish/config/api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'invoice_pesanan_page.dart';

class DetailPesananPage extends StatelessWidget {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final Map data;

  DetailPesananPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Color warnaStatus = Colors.orange;

    if (data["status"] == "Diproses") {
      warnaStatus = Colors.blue;
    } else if (data["status"] == "Selesai") {
      warnaStatus = Colors.green;
    } else if (data["status"] == "Dibatalkan") {
      warnaStatus = Colors.red;
    }

    String displayNamaIkan = "";
    final listItems = data["items"] as List?;
    if (listItems != null && listItems.isNotEmpty) {
      displayNamaIkan = listItems.map((e) => e["nama_ikan"] ?? "").join(" + ");
    } else {
      displayNamaIkan = data["nama_ikan"] ?? "-";
    }

    String fotoIkan = "";
    if ((data["items"] as List?) != null &&
        (data["items"] as List).isNotEmpty) {
      fotoIkan = (data["items"] as List)[0]["foto_ikan"] ?? "";
    } else {
      fotoIkan = data["foto_ikan"] ?? "";
    }

    double totalHarga = double.tryParse(data["total_pembayaran"]?.toString() ?? "") ?? 
                         double.tryParse(data["total_harga"]?.toString() ?? "") ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Detail Pesanan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoicePesananPage(data: data),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// MAIN HEADER CARD (Image 1 Mockup Style)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      "${Api.baseUrl}/uploads/$fotoIkan",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 180,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: warnaStatus.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          data["status"] ?? "-",
                          style: GoogleFonts.poppins(
                            color: warnaStatus,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (data["jenis_pesanan"]?.toString().toLowerCase().replaceAll(' ', '') == "preorder")
                              ? Colors.orange.shade50
                              : const Color(0xFFEBF5FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (data["jenis_pesanan"]?.toString().toLowerCase().replaceAll(' ', '') == "preorder")
                              ? "PRE-ORDER"
                              : "BELI LANGSUNG",
                          style: GoogleFonts.poppins(
                            color: (data["jenis_pesanan"]?.toString().toLowerCase().replaceAll(' ', '') == "preorder")
                                ? Colors.orange.shade700
                                : const Color(0xFF0060A9),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    displayNamaIkan,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Details List
                  itemDetail(
                    Icons.person_outline,
                    "Pembeli:",
                    data["nama_pembeli"] ?? data["nama_lengkap"] ?? "-",
                  ),
                  const SizedBox(height: 4),
                  itemDetail(
                    Icons.phone_outlined,
                    "No HP:",
                    data["no_hp_pembeli"] ?? data["no_telp"] ?? "-",
                  ),
                  const SizedBox(height: 4),
                  itemDetail(
                    Icons.payments_outlined,
                    "Total Pembayaran:",
                    rupiah.format(totalHarga),
                    highlightValue: true,
                  ),
                  const SizedBox(height: 4),
                  itemDetail(
                    Icons.credit_card_outlined,
                    "Metode:",
                    data["metode_pembayaran"].toString().toLowerCase(),
                  ),
                  const SizedBox(height: 4),
                  itemDetail(
                    Icons.local_shipping_outlined,
                    "Pengambilan:",
                    data["metode_pengambilan"].toString().toLowerCase(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CARD ITEM PESANAN (Image 1 Mockup Style)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Item Pesanan",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (listItems != null && listItems.isNotEmpty)
                    ...listItems.map((item) {
                      final nama = item["nama_ikan"] ?? "-";
                      final qty = item["jumlah_pesan"] ?? item["jumlah"] ?? "-";
                      final harga = double.tryParse(item["harga"].toString()) ?? 0;
                      final sub = double.tryParse(item["subtotal"].toString()) ?? 0;
                      final foto = item["foto_ikan"] ?? "";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                "${Api.baseUrl}/uploads/$foto",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.image,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nama,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    "${rupiah.format(harga)} x $qty Kg",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              rupiah.format(sub),
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50)),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            "${Api.baseUrl}/uploads/$fotoIkan",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade100,
                                child: const Icon(
                                  Icons.image,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data["nama_ikan"] ?? "-",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              Text(
                                "${rupiah.format(double.tryParse(data["harga"].toString()) ?? 0)} x ${data["jumlah_kg"]} Kg",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          rupiah.format(double.tryParse(data["total_harga"].toString()) ?? 0),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Status Pesanan (Image 2 style)
            Text(
              "Status Pesanan",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  statusItem(
                    "Pesanan Dibuat",
                    "Permintaan order dikirim oleh pembeli",
                    true,
                    Colors.green,
                    isFirst: true,
                  ),
                  statusItem(
                    "Menunggu Konfirmasi",
                    "Menunggu persetujuan dari pihak Agen",
                    data["status"] == "Menunggu" ||
                        data["status"] == "Diproses" ||
                        data["status"] == "Selesai",
                    Colors.orange,
                  ),
                  statusItem(
                    "Diproses Agen",
                    "Pesanan sedang disiapkan atau diantar",
                    data["status"] == "Diproses" || data["status"] == "Selesai",
                    Colors.blue,
                  ),
                  statusItem(
                    "Pesanan Selesai",
                    "Transaksi selesai dan diterima pembeli",
                    data["status"] == "Selesai",
                    Colors.green,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),


            // Back Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF0060A9,
                  ), // Matching deep blue color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Kembali ke Riwayat",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemDetail(
    IconData icon,
    String title,
    String value, {
    bool highlightValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF0060A9)),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: highlightValue ? 16 : 14,
                color: highlightValue
                    ? const Color(0xFF0060A9)
                    : const Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusItem(
    String title,
    String subtitle,
    bool aktif,
    Color warna, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              // Circle Avatar Step Icon
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: aktif ? warna.withOpacity(0.12) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: aktif ? warna : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: aktif ? warna : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              // Connecting line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: aktif ? warna : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: aktif
                          ? const Color(0xFF2C3E50)
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: aktif
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
