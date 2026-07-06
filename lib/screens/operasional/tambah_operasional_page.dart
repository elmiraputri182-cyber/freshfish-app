import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahOperasionalPage extends StatefulWidget {
  const TambahOperasionalPage({super.key});

  @override
  State<TambahOperasionalPage> createState() => _TambahOperasionalPageState();
}

class _TambahOperasionalPageState extends State<TambahOperasionalPage> {
  final namaController = TextEditingController();
  final noHpController = TextEditingController();
  final alamatController = TextEditingController();
  final lokasiController = TextEditingController();
  final keteranganController = TextEditingController();

  String status = "Melaut";
  DateTime tanggalBerangkat = DateTime.now();
  DateTime estimasiKembali = DateTime.now().add(const Duration(days: 2));
  bool loading = false;

  Future<void> pilihTanggalBerangkat() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: tanggalBerangkat,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (hasil != null) {
      setState(() {
        tanggalBerangkat = hasil;
      });
    }
  }

  Future<void> pilihEstimasi() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: estimasiKembali,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (hasil != null) {
      setState(() {
        estimasiKembali = hasil;
      });
    }
  }

  Future<void> simpan() async {
    if (namaController.text.isEmpty ||
        noHpController.text.isEmpty ||
        alamatController.text.isEmpty ||
        lokasiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lengkapi semua data terlebih dahulu"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final pref = await SharedPreferences.getInstance();
      final idUser = pref.getString("id_user") ?? "";

      final response = await http.post(
        Uri.parse("${Api.baseUrl}/operasional/tambah_operasional.php"),
        body: {
          "id_agen": idUser,
          "nama_nelayan": namaController.text,
          "no_hp": noHpController.text,
          "alamat": alamatController.text,
          "status": status,
          "tanggal_berangkat": DateFormat(
            "yyyy-MM-dd",
          ).format(tanggalBerangkat),
          "estimasi_kembali": DateFormat("yyyy-MM-dd").format(estimasiKembali),
          "lokasi": lokasiController.text,
          "keterangan": keteranganController.text,
        },
      );

      final hasil = jsonDecode(response.body);

      setState(() {
        loading = false;
      });

      if (hasil["success"] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Status operasional berhasil ditambahkan"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasil["message"].toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF2C3E50)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF0060A9), size: 20),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0060A9), width: 1.5),
        ),
      ),
    );
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
          "Tambah Operasional",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linear Gradient Header Banner
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Operasional Nelayan Mitra",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tambah Jadwal Melaut",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form container
            Container(
              padding: const EdgeInsets.all(20),
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
                  buildTextField(
                    namaController,
                    "Nama Nelayan",
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),
                  buildTextField(noHpController, "No HP", Icons.phone_outlined),
                  const SizedBox(height: 14),
                  buildTextField(
                    alamatController,
                    "Alamat Nelayan",
                    Icons.home_outlined,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: status,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF2C3E50),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: "Status Operasional",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: const Icon(
                        Icons.sailing_rounded,
                        color: Color(0xFF0060A9),
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF0060A9),
                          width: 1.5,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Melaut", child: Text("Melaut")),
                      DropdownMenuItem(
                        value: "Kembali",
                        child: Text("Kembali"),
                      ),
                      DropdownMenuItem(value: "Libur", child: Text("Libur")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          status = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF0060A9),
                      size: 20,
                    ),
                    title: Text(
                      "Tanggal Berangkat",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat("dd MMM yyyy").format(tanggalBerangkat),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    onTap: pilihTanggalBerangkat,
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    leading: const Icon(
                      Icons.schedule_outlined,
                      color: Color(0xFF0060A9),
                      size: 20,
                    ),
                    title: Text(
                      "Estimasi Kembali",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat("dd MMM yyyy").format(estimasiKembali),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    onTap: pilihEstimasi,
                  ),
                  const SizedBox(height: 14),
                  buildTextField(
                    lokasiController,
                    "Lokasi Melaut",
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: keteranganController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF2C3E50),
                    ),
                    decoration: InputDecoration(
                      labelText: "Keterangan (Opsional)",
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF0060A9),
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF0060A9),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0060A9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: loading ? null : simpan,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "SIMPAN STATUS",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
  }
}
