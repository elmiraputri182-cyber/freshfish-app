import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data_ikan_page.dart';
import 'tambah_ikan_page.dart';
import 'pesanan_masuk_page.dart';
import '../operasional/operasional_page.dart';
import 'package:intl/intl.dart';

class HomeAgenPage extends StatefulWidget {
  const HomeAgenPage({super.key});

  @override
  State<HomeAgenPage> createState() => _HomeAgenPageState();
}

class _HomeAgenPageState extends State<HomeAgenPage> {
  final format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int totalStok = 0;
  int totalPesanan = 0;
  int totalNelayan = 0;
  String namaLengkap = "Agen";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final idUser = pref.getString("id_user") ?? "";
      final nama =
          pref.getString("nama") ?? pref.getString("nama_lengkap") ?? "Agen";

      setState(() {
        namaLengkap = nama;
      });

      // Ambil data ikan (stok)
      final ikanResponse = await http.get(
        Uri.parse("${Api.baseUrl}/get_data_ikan.php?id_user=$idUser"),
      );

      if (ikanResponse.statusCode == 200) {
        final ikanData = jsonDecode(ikanResponse.body);
        if (ikanData["success"] == true) {
          final ikanList = ikanData["data"] as List;
          int stok = 0;
          for (var ikan in ikanList) {
            stok += int.tryParse(ikan["jumlah"].toString()) ?? 0;
          }
          setState(() {
            totalStok = stok;
          });
        }
      }

      // Ambil data pesanan
      final pesananResponse = await http.get(
        Uri.parse("${Api.baseUrl}/get_pemesanan_agen.php?id_user=$idUser"),
      );

      if (pesananResponse.statusCode == 200) {
        final pesananData = jsonDecode(pesananResponse.body);
        if (pesananData["success"] == true) {
          final pesananList = pesananData["data"] as List;
          setState(() {
            totalPesanan = pesananList.length;
          });
        }
      }

      final nelayanResponse = await http.get(
        Uri.parse(
          "${Api.baseUrl}/operasional/get_operasional.php?id_agen=$idUser",
        ),
      );

      if (nelayanResponse.statusCode == 200) {
        final nelayanData = jsonDecode(nelayanResponse.body);
        if (nelayanData["success"] == true) {
          final list = nelayanData["data"] as List;
          setState(() {
            totalNelayan = list.length;
          });
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    String initial = namaLengkap.isNotEmpty
        ? namaLengkap[0].toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0060A9)),
            )
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              color: const Color(0xFF0060A9),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${getGreeting()},",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                namaLengkap,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0060A9),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Operational Banner
                      Container(
                        padding: const EdgeInsets.all(18),
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
                                Icons.sailing,
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
                                    "Aktivitas Nelayan Bengkalis",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Pantau status melaut & ketersediaan hasil tangkapan nelayan",
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
                      const SizedBox(height: 24),

                      // Quick Stats Grid
                      Row(
                        children: [
                          buildStatCard(
                            totalStok.toString(),
                            "Stok (Kg)",
                            Icons.set_meal_outlined,
                            const Color(0xFF0060A9),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DataIkanPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          buildStatCard(
                            totalPesanan.toString(),
                            "Pesanan",
                            Icons.shopping_bag_outlined,
                            Colors.orange.shade700,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PesananMasukPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          buildStatCard(
                            totalNelayan.toString(),
                            "Nelayan",
                            Icons.people_alt_outlined,
                            Colors.green.shade600,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OperasionalPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Main Menu
                      Text(
                        "Menu Utama",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Refactored sleek menu list items (instead of blocky stretched cards)
                      buildMenuRowItem(
                        context,
                        Icons.inventory_2_outlined,
                        "Kelola Data Ikan",
                        "Lihat, ubah harga, dan hapus stok ikan Anda",
                        const Color(0xFF0060A9),
                        "data_ikan",
                      ),
                      buildMenuRowItem(
                        context,
                        Icons.add_circle_outline_rounded,
                        "Tambah Ikan Baru",
                        "Posting jenis ikan baru ke daftar penjualan",
                        Colors.orange.shade700,
                        "tambah_ikan",
                      ),
                      buildMenuRowItem(
                        context,
                        Icons.directions_boat_outlined,
                        "Status Operasional Nelayan",
                        "Perbarui jadwal melaut dan libur nelayan mitra",
                        Colors.green.shade600,
                        "operasional",
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildStatCard(
    String angka,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    angka,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }

  Widget buildMenuRowItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String pageType,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Widget page;
            switch (pageType) {
              case "data_ikan":
                page = const DataIkanPage();
                break;
              case "tambah_ikan":
                page = TambahIkanPage(onSuccess: () {});
                break;
              case "operasional":
                page = const OperasionalPage();
                break;
              default:
                page = const DataIkanPage();
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
