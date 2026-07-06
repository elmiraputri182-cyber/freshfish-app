import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'data_pesanan_page.dart';

class LaporanAdminPage extends StatefulWidget {
  const LaporanAdminPage({super.key});

  @override
  State<LaporanAdminPage> createState() => _LaporanAdminPageState();
}

class _LaporanAdminPageState extends State<LaporanAdminPage> {
  final rupiah = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  bool loading = true;
  Map laporan = {};

  @override
  void initState() {
    super.initState();
    getLaporan();
  }

  Future<void> getLaporan() async {
    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/admin/get_laporan_admin.php"),
      );

      final json = jsonDecode(response.body);

      if (json["success"] == true || json["success"] == "true") {
        setState(() {
          laporan = json;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        loading = false;
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
          "Laporan Admin",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0060A9)),
            )
          : RefreshIndicator(
              onRefresh: getLaporan,
              color: const Color(0xFF0060A9),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0060A9), Color(0xFF2196F3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0060A9).withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dashboard Laporan",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Ringkasan metrik performa & statistik penjualan sistem",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Summary Grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      buildCard(
                        "Pembeli",
                        laporan["total_pembeli"].toString(),
                        Icons.people_alt_outlined,
                        Colors.orange.shade700,
                      ),
                      buildCard(
                        "Agen Mitra",
                        laporan["total_agen"].toString(),
                        Icons.storefront_outlined,
                        Colors.teal.shade600,
                      ),
                      buildCard(
                        "Total Pesanan",
                        laporan["total_pesanan"].toString(),
                        Icons.shopping_bag_outlined,
                        const Color(0xFF0060A9),
                      ),
                      buildCard(
                        "Total Pendapatan",
                        rupiah.format(laporan["total_pendapatan"]),
                        Icons.payments_outlined,
                        Colors.green.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Status Title
                  Text(
                    "Statistik Status Pesanan",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Rows Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
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
                        buildStatus(
                          Colors.orange.shade700,
                          Icons.access_time_outlined,
                          "Menunggu Konfirmasi",
                          laporan["menunggu"].toString(),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DataPesananPage(
                                  initialStatus: "Menunggu",
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        buildStatus(
                          const Color(0xFF0060A9),
                          Icons.sync_outlined,
                          "Pesanan Diproses",
                          laporan["diproses"].toString(),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DataPesananPage(
                                  initialStatus: "Diproses",
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        buildStatus(
                          Colors.green.shade600,
                          Icons.check_circle_outline_rounded,
                          "Pesanan Selesai",
                          laporan["selesai"].toString(),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DataPesananPage(
                                  initialStatus: "Selesai",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatus(
    Color color,
    IconData icon,
    String title,
    String jumlah,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                jumlah,
                style: GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
