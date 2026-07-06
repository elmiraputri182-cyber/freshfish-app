import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'edit_ikan_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataIkanPage extends StatefulWidget {
  const DataIkanPage({super.key});

  @override
  State<DataIkanPage> createState() => _DataIkanPageState();
}

class _DataIkanPageState extends State<DataIkanPage> {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  List dataIkan = [];

  Future<void> getDataIkan() async {
    final prefs = await SharedPreferences.getInstance();
    String idAgen = prefs.getString("id_user") ?? "";

    final response = await http.post(
      Uri.parse("${Api.baseUrl}/get_data_ikan.php"),
      body: {"id_agen": idAgen},
    );

    final json = jsonDecode(response.body);

    if (json["success"] == true) {
      setState(() {
        dataIkan = json["data"];
      });
    }
  }

  Future<void> hapusIkan(String id) async {
    final response = await http.post(
      Uri.parse("${Api.baseUrl}/hapus_ikan.php"),
      body: {"id_ikan": id},
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      getDataIkan();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showEditDialog(dynamic ikan) {
    showDialog(
      context: context,
      builder: (context) {
        return EditIkanPage(ikan: ikan, onSuccess: getDataIkan);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getDataIkan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          "Kelola Data Ikan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
      ),
      body: dataIkan.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.set_meal_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Data ikan kosong",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: dataIkan.length,
              itemBuilder: (context, index) {
                final ikan = dataIkan[index];

                final bool ready =
                    (ikan["status_tersedia"] ?? "").toString().toLowerCase() ==
                    "ready";
                final Color statusColor = ready
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFEF6C00);
                final Color bgColor = ready
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFF3E0);

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
                      if (ikan["foto_ikan"] != null && ikan["foto_ikan"] != "")
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            "${Api.baseUrl}/uploads/${ikan["foto_ikan"]}",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: Colors.grey.shade100,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ikan["nama_ikan"] ?? "-",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ready ? "Ready" : "Pre Order",
                              style: GoogleFonts.poppins(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Kategori: ${ikan["kategori"] ?? "-"}",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Stok: ${ikan["jumlah"] ?? "0"} KG",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            rupiah.format(
                              num.tryParse(ikan["harga"].toString()) ?? 0,
                            ),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF0060A9),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey.shade500,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Lat: ${ikan["latitude"]} | Long: ${ikan["longitude"]}",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                              onPressed: () {
                                _showEditDialog(ikan);
                              },
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text(
                                "Edit",
                                style: GoogleFonts.poppins(
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
                                hapusIkan(ikan["id_ikan"].toString());
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
    );
  }
}
