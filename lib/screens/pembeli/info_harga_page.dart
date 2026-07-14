import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'detail_ikan_page.dart';
import 'package:intl/intl.dart';

class InfoHargaPage extends StatefulWidget {
  const InfoHargaPage({super.key});

  @override
  State<InfoHargaPage> createState() => _InfoHargaPageState();
}

class _InfoHargaPageState extends State<InfoHargaPage> {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List ikanList = [];
  String kategoriDipilih = "Semua";

  List get ikanFilter {
    if (kategoriDipilih == "Semua") {
      return ikanList;
    }

    return ikanList.where((item) {
      return item["kategori"] == kategoriDipilih;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    getDataIkan();
  }

  Future getDataIkan() async {
    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/pembeli/get_info_harga.php"),
      );

      print("STATUS = ${response.statusCode}");
      print("BODY = ${response.body}");

      final json = jsonDecode(response.body);
      setState(() {
        ikanList = json["data"] ?? [];
      });
    } catch (e) {
      print("ERROR = $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Info Harga Ikan",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          SizedBox(
            height: 68,

            child: ListView(
              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

              children: [
                kategoriButton("Semua"),

                kategoriButton("Ikan Laut"),

                kategoriButton("Ikan Tawar"),

                kategoriButton("Udang"),

                kategoriButton("Kerang"),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: getDataIkan,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: ikanFilter.length,
                itemBuilder: (context, index) {
                  final ikan = ikanFilter[index];

                  double harga = double.tryParse(ikan["harga"].toString()) ?? 0;

                  double hargaLama =
                      double.tryParse(ikan["harga_lama"]?.toString() ?? "0") ??
                      0;

                  String statusHarga = "STABIL";

                  if (hargaLama != 0 && hargaLama != harga) {
                    bool isValidInterval = true;
                    if (ikan["tanggal_update_harga"] != null) {
                      try {
                        DateTime tanggalUpdate = DateTime.parse(ikan["tanggal_update_harga"].toString());
                        DateTime sekarang = DateTime.now();
                        
                        DateTime tUpdateOnlyDate = DateTime(tanggalUpdate.year, tanggalUpdate.month, tanggalUpdate.day);
                        DateTime sekarangOnlyDate = DateTime(sekarang.year, sekarang.month, sekarang.day);
                        int selisihHari = sekarangOnlyDate.difference(tUpdateOnlyDate).inDays;

                        if (selisihHari > 3) {
                          isValidInterval = false;
                        }
                      } catch (_) {
                        // Jika gagal parsing, biarkan true (fallback aman)
                      }
                    }

                    if (isValidInterval) {
                      if (harga > hargaLama) {
                        statusHarga = "NAIK";
                      } else if (harga < hargaLama) {
                        statusHarga = "TURUN";
                      }
                    }
                  }

                  // Trend badge styling
                  Color trendBgColor = const Color(0xFFF3F4F6); // Grey
                  Color trendTextColor = const Color(0xFF4B5563);
                  String trendText = "Harga STABIL";
                  IconData trendIcon = Icons.trending_flat;

                  if (statusHarga == "NAIK") {
                    trendBgColor = const Color(0xFFFFF0F0); // Light red/pink
                    trendTextColor = const Color(0xFFD9383A); // Red
                    trendText = "Harga NAIK";
                    trendIcon = Icons.arrow_upward;
                  } else if (statusHarga == "TURUN") {
                    trendBgColor = const Color(0xFFEBFDF5); // Light green
                    trendTextColor = const Color(0xFF10B981); // Green
                    trendText = "Harga TURUN";
                    trendIcon = Icons.arrow_downward;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailIkanPage(ikan: ikan),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fish Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  "${Api.baseUrl}/uploads/${ikan["foto_ikan"]}",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.image,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Details Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "TANGKAPAN UTAMA",
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        // Ready/Pre-order badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                ikan["status_tersedia"] ==
                                                    "ready"
                                                ? const Color(0xFFE8F5E9)
                                                : const Color(0xFFFFF3E0),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            ikan["status_tersedia"] == "ready"
                                                ? "READY"
                                                : "PRE ORDER",
                                            style: GoogleFonts.poppins(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  ikan["status_tersedia"] ==
                                                      "ready"
                                                  ? const Color(0xFF2E7D32)
                                                  : const Color(0xFFE65100),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      ikan["nama_ikan"],
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${rupiah.format(harga)} /Kg",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(
                                          0xFF0060A9,
                                        ), // The beautiful blue color
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Trend Indicator Pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: trendBgColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            trendIcon,
                                            size: 12,
                                            color: trendTextColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            trendText,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: trendTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Location & Agent Row Container
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF4F7FC,
                              ), // Soft blue/grey background box
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                // Location Section
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.01,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Color(0xFF0060A9),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "LOKASI",
                                              style: GoogleFonts.poppins(
                                                fontSize: 8,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              ikan["alamat"] ?? "-",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF2C3E50),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider Line
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 12),
                                // Agent Section
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.01,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person_outline,
                                          size: 14,
                                          color: Color(0xFF0060A9),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "AGEN",
                                              style: GoogleFonts.poppins(
                                                fontSize: 8,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              ikan["nama_lengkap"] ?? "-",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF2C3E50),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget kategoriButton(String kategori) {
    bool isSelected = kategoriDipilih == kategori;

    return GestureDetector(
      onTap: () {
        setState(() {
          kategoriDipilih = kategori;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0060A9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0060A9)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            kategori,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
