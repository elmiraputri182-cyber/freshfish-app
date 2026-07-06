import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class DataPembeliPage extends StatefulWidget {
  const DataPembeliPage({super.key});

  @override
  State<DataPembeliPage> createState() => _DataPembeliPageState();
}

class _DataPembeliPageState extends State<DataPembeliPage> {
  List dataPembeli = [];
  List filterPembeli = [];
  bool isLoading = true;

  final TextEditingController cariController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDataPembeli();
    cariController.addListener(() {
      cariPembeli();
    });
  }

  Future<void> getDataPembeli() async {
    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/admin/get_pembeli.php"),
      );

      final json = jsonDecode(response.body);

      if (json["success"] == true) {
        setState(() {
          dataPembeli = json["data"];
          filterPembeli = dataPembeli;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void cariPembeli() {
    String keyword = cariController.text.toLowerCase();
    setState(() {
      filterPembeli = dataPembeli.where((item) {
        final nama = item["nama_lengkap"]?.toString().toLowerCase() ?? "";
        final username = item["username"]?.toString().toLowerCase() ?? "";
        return nama.contains(keyword) || username.contains(keyword);
      }).toList();
    });
  }

  Future<void> hapusPembeli(String idUser) async {
    try {
      final response = await http.post(
        Uri.parse("${Api.baseUrl}/admin/delete_user.php"),
        body: {"id_user": idUser},
      );

      final json = jsonDecode(response.body);

      if (json["success"] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Data pembeli berhasil dihapus",
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        getDataPembeli();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          "Data Pembeli",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0060A9)),
            )
          : RefreshIndicator(
              onRefresh: getDataPembeli,
              color: const Color(0xFF0060A9),
              child: Column(
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 14),
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
                            Icons.people_alt_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Pembeli Terdaftar",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${filterPembeli.length} Orang",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    child: TextField(
                      controller: cariController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF0060A9),
                        ),
                        hintText: "Cari pembeli berdasarkan nama...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // List Data
                  Expanded(
                    child: filterPembeli.isEmpty
                        ? Center(
                            child: Text(
                              "Data pembeli tidak ditemukan",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: filterPembeli.length,
                            itemBuilder: (context, index) {
                              final item = filterPembeli[index];
                              final String initial =
                                  item["nama_lengkap"] != null &&
                                      item["nama_lengkap"].toString().isNotEmpty
                                  ? item["nama_lengkap"][0].toUpperCase()
                                  : "P";
                              final String noHp =
                                  item["no_telp"] ?? item["no_hp"] ?? "-";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(
                                          0xFF0060A9,
                                        ).withOpacity(0.08),
                                        child: Text(
                                          initial,
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF0060A9),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item["nama_lengkap"] ?? "-",
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF2C3E50),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            infoRow(
                                              Icons.email_outlined,
                                              Colors.blue,
                                              item["username"] ?? "-",
                                            ),
                                            const SizedBox(height: 4),
                                            infoRow(
                                              Icons.phone_outlined,
                                              Colors.green,
                                              noHp,
                                            ),
                                            const SizedBox(height: 4),
                                            infoRow(
                                              Icons.location_on_outlined,
                                              Colors.red,
                                              item["alamat"] ?? "-",
                                            ),
                                            const SizedBox(height: 14),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFFD32F2F,
                                                  ),
                                                  side: const BorderSide(
                                                    color: Color(0xFFE2E8F0),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 8,
                                                      ),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                24,
                                                              ),
                                                        ),
                                                        title: Text(
                                                          "Hapus Pembeli",
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    const Color(
                                                                      0xFF2C3E50,
                                                                    ),
                                                              ),
                                                        ),
                                                        content: Text(
                                                          "Apakah Anda yakin ingin menghapus pembeli ini?",
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                              ),
                                                        ),
                                                        actionsPadding:
                                                            const EdgeInsets.fromLTRB(
                                                              16,
                                                              0,
                                                              16,
                                                              16,
                                                            ),
                                                        actions: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: OutlinedButton(
                                                                  style: OutlinedButton.styleFrom(
                                                                    foregroundColor:
                                                                        const Color(
                                                                          0xFF2C3E50,
                                                                        ),
                                                                    side: const BorderSide(
                                                                      color: Color(
                                                                        0xFFE2E8F0,
                                                                      ),
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10,
                                                                        ),
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    "Batal",
                                                                    style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 12,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        const Color(
                                                                          0xFFD32F2F,
                                                                        ),
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    elevation:
                                                                        0,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            12,
                                                                          ),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              10,
                                                                        ),
                                                                  ),
                                                                  onPressed: () {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                    hapusPembeli(
                                                                      item["id_user"]
                                                                          .toString(),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    "Hapus",
                                                                    style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  size: 16,
                                                ),
                                                label: Text(
                                                  "Hapus",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
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
                ],
              ),
            ),
    );
  }

  Widget infoRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
