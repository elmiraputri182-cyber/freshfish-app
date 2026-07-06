import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/pdf_service.dart';

class LaporanAgenPage extends StatefulWidget {
  const LaporanAgenPage({super.key});

  @override
  State<LaporanAgenPage> createState() => _LaporanAgenPageState();
}

class _LaporanAgenPageState extends State<LaporanAgenPage> {
  final NumberFormat rupiah = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  bool isLoading = true;
  String filter = "Bulanan";
  List laporan = [];

  int totalPesanan = 0;
  int totalPemasukan = 0;
  int totalKg = 0;
  int totalPembeli = 0;

  String idUser = "";

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final pref = await SharedPreferences.getInstance();
    idUser = pref.getString("id_user") ?? "";
    await getLaporan();
  }

  Future<void> getLaporan() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          "${Api.baseUrl}/get_laporan_agen.php?id_user=$idUser&filter=$filter",
        ),
      );

      final json = jsonDecode(response.body);

      if (json["success"] == true) {
        laporan = json["data"];
        totalPesanan = int.tryParse(json["total_pesanan"].toString()) ?? 0;
        totalPemasukan = int.tryParse(json["total_pemasukan"].toString()) ?? 0;
        totalKg = 0;

        Set<String> pembeli = {};
        for (var item in laporan) {
          totalKg += int.tryParse(item["jumlah_kg"].toString()) ?? 0;
          pembeli.add(item["id_user"].toString());
        }
        totalPembeli = pembeli.length;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F9FD),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          "Laporan Penjualan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: getLaporan,
          color: const Color(0xFF0060A9),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                // Filter Dropdown
                buildFilter(),
                const SizedBox(height: 20),

                // Section: Ringkasan
                Text(
                  "Ringkasan Penjualan",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                buildRingkasan(),
                const SizedBox(height: 20),

                // Button PDF download
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      PdfService.cetakLaporan(
                        laporan: laporan,
                        totalPesanan: totalPesanan,
                        totalPemasukan: totalPemasukan,
                        totalKg: totalKg,
                        totalPembeli: totalPembeli,
                        filter: filter,
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                    label: Text(
                      "Unduh Laporan PDF",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Section: Daftar transaksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Daftar Transaksi",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0060A9).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${laporan.length} Transaksi",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0060A9),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                buildDaftarTransaksi(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filter,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF0060A9),
          ),
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          items: const [
            DropdownMenuItem(
              value: "mingguan",
              child: Text("Laporan Mingguan"),
            ),
            DropdownMenuItem(value: "Bulanan", child: Text("Laporan Bulanan")),
            DropdownMenuItem(value: "tahunan", child: Text("Laporan Tahunan")),
          ],
          onChanged: (value) async {
            if (value != null) {
              setState(() {
                filter = value;
              });
              await getLaporan();
            }
          },
        ),
      ),
    );
  }

  Widget buildRingkasan() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildCard(
                title: "Total Pesanan",
                value: "$totalPesanan",
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFF0060A9),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildCard(
                title: "Total Pendapatan",
                value: rupiah.format(totalPemasukan),
                icon: Icons.payments_outlined,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildCard(
                title: "Total Berat (Kg)",
                value: "$totalKg Kg",
                icon: Icons.scale_outlined,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildCard(
                title: "Jumlah Pembeli",
                value: "$totalPembeli",
                icon: Icons.people_outline,
                color: Colors.purple.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTransaksiCard(dynamic item) {
    Color warnaStatus = Colors.green;
    final String currentStatus = item["status"].toString().trim();
    if (currentStatus == "Menunggu" || currentStatus == "Menunggu Konfirmasi") {
      warnaStatus = Colors.orange;
    } else if (currentStatus == "Diproses") {
      warnaStatus = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pesanan #${item["kode_pesanan"]}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: warnaStatus.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item["status"] ?? "-",
                  style: GoogleFonts.poppins(
                    color: warnaStatus,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Clean product list item
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.set_meal_outlined,
                  color: Color(0xFF0060A9),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item["nama_ikan"] ?? "-",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Sleek clean rows
          infoRow(
            Icons.person_outline_rounded,
            Colors.blue,
            "Pembeli",
            item["nama_lengkap"] ?? "-",
          ),
          const SizedBox(height: 8),
          infoRow(
            Icons.payments_outlined,
            Colors.green,
            "Metode",
            item["metode_pembayaran"] ?? "-",
          ),
          const SizedBox(height: 8),
          infoRow(
            Icons.scale_outlined,
            Colors.orange,
            "Jumlah",
            "${item["jumlah_kg"]} Kg",
          ),
          const SizedBox(height: 8),
          infoRow(
            Icons.calendar_today_outlined,
            Colors.red,
            "Tanggal",
            item["tanggal"] ?? "-",
          ),

          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Pendapatan",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              Text(
                rupiah.format(
                  int.tryParse(item["total_harga"].toString()) ?? 0,
                ),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4CAF50),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, Color color, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Text(
          "$title:",
          style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDaftarTransaksi() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF0060A9)),
        ),
      );
    }

    if (laporan.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 70,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 14),
            Text(
              "Belum Ada Laporan",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Data transaksi akan muncul di sini",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: laporan.length,
      itemBuilder: (context, index) {
        return buildTransaksiCard(laporan[index]);
      },
    );
  }
}
