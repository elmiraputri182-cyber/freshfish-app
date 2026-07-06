import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'tambah_operasional_page.dart';
import 'edit_operasional_page.dart';

class OperasionalPage extends StatefulWidget {
  const OperasionalPage({super.key});

  @override
  State<OperasionalPage> createState() => _OperasionalPageState();
}

class _OperasionalPageState extends State<OperasionalPage> {
  List dataOperasional = [];
  bool isLoading = true;

  Future<void> getOperasional() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final idUser = pref.getString("id_user") ?? "";

      final response = await http.get(
        Uri.parse(
          "${Api.baseUrl}/operasional/get_operasional.php?id_agen=$idUser",
        ),
      );

      final json = jsonDecode(response.body);

      if (json["success"] == true) {
        setState(() {
          dataOperasional = json["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> hapusOperasional(String idNelayan) async {
    final konfirmasi = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Konfirmasi Hapus",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          content: Text(
            "Yakin ingin menghapus data operasional nelayan ini?",
            style: GoogleFonts.poppins(color: Colors.grey.shade600),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C3E50),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Batal",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      "Hapus",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (konfirmasi != true) {
      return;
    }

    final response = await http.post(
      Uri.parse("${Api.baseUrl}/operasional/hapus_operasional.php"),
      body: {"id_nelayan": idNelayan},
    );

    final hasil = jsonDecode(response.body);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hasil["message"].toString()),
        backgroundColor: Colors.green,
      ),
    );

    getOperasional();
  }

  @override
  void initState() {
    super.initState();
    getOperasional();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        centerTitle: true,
        title: Text(
          "Status Operasional",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0060A9),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahOperasionalPage()),
          );
          if (refresh == true) {
            getOperasional();
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: getOperasional,
        color: const Color(0xFF0060A9),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0060A9)),
              )
            : dataOperasional.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.directions_boat_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "Belum Ada Status Operasional",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                itemCount: dataOperasional.length,
                itemBuilder: (context, index) {
                  final item = dataOperasional[index];

                  Color warna = Colors.green;
                  if (item["status"] == "Melaut") {
                    warna = Colors.blue;
                  } else if (item["status"] == "Libur") {
                    warna = Colors.orange.shade700;
                  } else if (item["status"] == "Kembali") {
                    warna = Colors.green.shade600;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: warna.withOpacity(.08),
                              child: Icon(
                                Icons.sailing_rounded,
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: warna.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item["status"] ?? "-",
                                      style: GoogleFonts.poppins(
                                        color: warna,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 14),
                        infoRow(
                          Icons.calendar_today_outlined,
                          const Color(0xFF0060A9),
                          "Tanggal Berangkat",
                          item["tanggal_berangkat"] ?? "-",
                        ),
                        const SizedBox(height: 8),
                        infoRow(
                          Icons.update_outlined,
                          Colors.orange.shade700,
                          "Estimasi Kembali",
                          item["estimasi_kembali"] ?? "-",
                        ),
                        const SizedBox(height: 8),
                        infoRow(
                          Icons.location_on_outlined,
                          Colors.red.shade600,
                          "Lokasi Melaut",
                          item["lokasi"] ?? "-",
                        ),
                        const SizedBox(height: 12),
                        if (item["keterangan"] != null &&
                            item["keterangan"]
                                .toString()
                                .trim()
                                .isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              item["keterangan"],
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0060A9),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditOperasionalPage(data: item),
                                    ),
                                  );
                                  getOperasional();
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                label: Text(
                                  "Edit",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFD32F2F),
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: () {
                                  hapusOperasional(
                                    item["id_nelayan"].toString(),
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
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
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
}
