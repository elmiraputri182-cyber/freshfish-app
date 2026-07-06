import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AktivitasNelayanPage extends StatefulWidget {
  const AktivitasNelayanPage({super.key});

  @override
  State<AktivitasNelayanPage> createState() => _AktivitasNelayanPageState();
}

class _AktivitasNelayanPageState extends State<AktivitasNelayanPage> {
  bool loading = true;

  List nelayan = [];

  List filtered = [];

  String filter = "Semua";

  Future<void> getNelayan() async {
    final response = await http.get(
      Uri.parse("${Api.baseUrl}/pembeli/get_semua_nelayan.php"),
    );

    final json = jsonDecode(response.body);

    if (json["success"]) {
      setState(() {
        nelayan = json["data"];

        filtered = nelayan;

        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getNelayan();
  }

  void filterStatus(String status) {
    setState(() {
      filter = status;

      if (status == "Semua") {
        filtered = nelayan;
      } else {
        filtered = nelayan.where((e) {
          return e["status"] == status;
        }).toList();
      }
    });
  }

  void cariNelayan(String keyword) {
    setState(() {
      // Jika kotak pencarian kosong
      if (keyword.trim().isEmpty) {
        if (filter == "Semua") {
          filtered = List.from(nelayan);
        } else {
          filtered = nelayan.where((e) {
            return (e["status"]?.toString() ?? "") == filter;
          }).toList();
        }
        return;
      }

      // Filter berdasarkan nama + status
      filtered = nelayan.where((e) {
        final nama = (e["nama_nelayan"]?.toString() ?? "").toLowerCase();

        final status = (e["status"]?.toString() ?? "");

        final cocokNama = nama.contains(keyword.toLowerCase());

        final cocokStatus = filter == "Semua" ? true : status == filter;

        return cocokNama && cocokStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        title: Text(
          "Aktivitas Nelayan",

          style: GoogleFonts.poppins(
            color: Colors.black,

            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildFilter(),

                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Icon(
                                Icons.sailing,

                                size: 70,

                                color: Colors.grey.shade400,
                              ),

                              const SizedBox(height: 20),

                              Text(
                                "Belum ada aktivitas nelayan",

                                style: GoogleFonts.poppins(
                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Coba ubah filter atau kata kunci pencarian.",

                                textAlign: TextAlign.center,

                                style: GoogleFonts.poppins(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: getNelayan,

                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),

                            itemCount: filtered.length,

                            itemBuilder: (context, index) {
                              return buildCard(filtered[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget buildFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          filterChip("Semua"),
          filterChip("Melaut"),
          filterChip("Kembali"),
          filterChip("Libur"),
        ],
      ),
    );
  }

  Widget filterChip(String title) {
    final aktif = filter == title;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        showCheckmark: false,
        label: Text(title),
        selected: aktif,
        onSelected: (_) {
          filterStatus(title);
        },
        selectedColor: const Color(0xFF0060A9),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: aktif ? const Color(0xFF0060A9) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        labelStyle: GoogleFonts.poppins(
          color: aktif ? Colors.white : const Color(0xFF64748B),
          fontWeight: aktif ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }

  Widget buildCard(Map item) {
    Color warna;
    IconData icon;

    switch (item["status"]) {
      case "Melaut":
        warna = Colors.green;
        icon = Icons.sailing_rounded;
        break;

      case "Kembali":
        warna = Colors.blue;
        icon = Icons.anchor_rounded;
        break;

      default:
        warna = Colors.orange;
        icon = Icons.hotel_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffEBF2FF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: warna.withOpacity(.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: warna,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["nama_nelayan"] ?? "-",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xff2C3E50),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Nelayan FreshFish",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: warna.withOpacity(.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 13, color: warna),
                      const SizedBox(width: 6),
                      Text(
                        item["status"] ?? "-",
                        style: GoogleFonts.poppins(
                          color: warna,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xffF2F6FC), height: 1),
            const SizedBox(height: 16),

            /// LOKASI & ESTIMASI
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF6FAFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffEBF2FF)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lokasi Aktivitas",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["lokasi"] ?? "-",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: const Color(0xff2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xffEBF2FF), height: 1),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_outlined,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Estimasi Kembali",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item["estimasi_kembali"] ?? "-",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: const Color(0xff2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
