import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'detail_pesanan_admin_page.dart';
import 'package:intl/intl.dart';

class DataPesananPage extends StatefulWidget {
  final String? initialStatus;

  const DataPesananPage({super.key, this.initialStatus});

  @override
  State<DataPesananPage> createState() => _DataPesananPageState();
}

class _DataPesananPageState extends State<DataPesananPage> {
  List dataPesanan = [];
  List filterPesanan = [];
  bool isLoading = true;
  String selectedStatus = "Semua";

  final TextEditingController cariController = TextEditingController();

  final rupiah = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialStatus != null) {
      selectedStatus = widget.initialStatus!;
    }
    getDataPesanan();
    cariController.addListener(() {
      cariPesanan();
    });
  }

  Future<void> getDataPesanan() async {
    try {
      final response = await http.get(
        Uri.parse("${Api.baseUrl}/admin/get_data_pesanan.php"),
      );

      final json = jsonDecode(response.body);

      if (json["success"] == true) {
        setState(() {
          dataPesanan = json["data"];
          if (selectedStatus == "Semua") {
            filterPesanan = dataPesanan;
          } else {
            filterPesanan = dataPesanan.where((item) {
              return item["status"] == selectedStatus;
            }).toList();
          }
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

  void cariPesanan() {
    String keyword = cariController.text.toLowerCase();
    setState(() {
      filterPesanan = dataPesanan.where((item) {
        final kodePesanan =
            item["kode_pesanan"]?.toString().toLowerCase() ?? "";
        final namaPembeli =
            item["nama_pembeli"]?.toString().toLowerCase() ?? "";
        final namaIkan = item["nama_ikan"]?.toString().toLowerCase() ?? "";

        return kodePesanan.contains(keyword) ||
            namaPembeli.contains(keyword) ||
            namaIkan.contains(keyword);
      }).toList();
    });
  }

  void filterStatus(String status) {
    setState(() {
      selectedStatus = status;
      if (status == "Semua") {
        filterPesanan = dataPesanan;
      } else {
        filterPesanan = dataPesanan.where((item) {
          return item["status"].toString() == status;
        }).toList();
      }
    });
  }

  Color warnaStatus(String status) {
    switch (status) {
      case "Menunggu":
        return Colors.orange;
      case "Diproses":
        return Colors.blue;
      case "Selesai":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget buildFilter(String status) {
    final bool isSelected = selectedStatus == status;

    return ChoiceChip(
      label: Text(
        status,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : const Color(0xFF2C3E50),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0060A9),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF0060A9) : const Color(0xFFE2E8F0),
      ),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        filterStatus(status);
      },
    );
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
          "Data Pesanan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0060A9)),
            )
          : RefreshIndicator(
              onRefresh: getDataPesanan,
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
                            Icons.shopping_bag_outlined,
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
                                "Total Pesanan",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${filterPesanan.length} Pesanan",
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
                        hintText: "Cari nomor pesanan, pembeli, ikan...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filter Chips
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: buildFilter("Semua"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: buildFilter("Menunggu"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: buildFilter("Diproses"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: buildFilter("Selesai"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // List Data
                  Expanded(
                    child: filterPesanan.isEmpty
                        ? Center(
                            child: Text(
                              "Data pesanan belum tersedia",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filterPesanan.length,
                            itemBuilder: (context, index) {
                              final item = filterPesanan[index];
                              return buildPesananCard(item);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildPesananCard(dynamic item) {
    Color warna = warnaStatus(item["status"]);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item["foto_ikan"] != null && item["foto_ikan"] != "")
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "${Api.baseUrl}/uploads/${item["foto_ikan"]}",
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 160,
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item["nama_ikan"] ?? "-",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Text(
                  item["kode_pesanan"] ?? "-",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0060A9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            infoRow(
              Icons.person_outline_rounded,
              Colors.blue,
              "Pembeli: ${item["nama_pembeli"] ?? "-"}",
            ),
            const SizedBox(height: 4),
            infoRow(
              Icons.storefront_outlined,
              Colors.green,
              "Agen: ${item["nama_agen"] ?? "-"}",
            ),
            const SizedBox(height: 4),
            infoRow(
              Icons.payments_outlined,
              Colors.orange,
              "Total: ${rupiah.format(num.tryParse(item["total_pembayaran"].toString()) ?? 0)}",
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: warna.withOpacity(0.08),
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
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0060A9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPesananAdminPage(data: item),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(
                    "Detail",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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
