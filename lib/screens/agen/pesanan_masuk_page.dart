import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/update_status_service.dart';
import 'detail_pesanan_page.dart';
import 'package:intl/intl.dart';

class PesananMasukPage extends StatefulWidget {
  const PesananMasukPage({super.key});

  @override
  State<PesananMasukPage> createState() => _PesananMasukPageState();
}

class _PesananMasukPageState extends State<PesananMasukPage> {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List pesanan = [];
  String filter = "Order";
  bool isLoading = true;

  Future<void> getPesanan() async {
    final pref = await SharedPreferences.getInstance();
    final idAgen = pref.getString("id_user") ?? "";

    final response = await http.get(
      Uri.parse("${Api.baseUrl}/get_pesanan_masuk_agen.php?id_agen=$idAgen"),
    );

    if (response.statusCode == 200) {
      final hasil = jsonDecode(response.body);
      setState(() {
        pesanan = hasil["data"] ?? [];
        isLoading = false;
      });
    }
  }

  void _showContactDialog(BuildContext context, String noHp, String nama) {
    String formattedPhone = noHp.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62' + formattedPhone.substring(1);
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hubungi Pembeli",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Pilih metode untuk menghubungi $nama ($noHp)",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              
              // WhatsApp Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                ),
                title: Text(
                  "Kirim WhatsApp",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                subtitle: Text("Hubungi via chat WhatsApp", style: GoogleFonts.poppins(fontSize: 11)),
                onTap: () async {
                  Navigator.pop(context);
                  final url = Uri.parse("https://wa.me/$formattedPhone");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const Divider(),
              
              // Direct Call Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_outlined, color: Colors.blue),
                ),
                title: Text(
                  "Telepon Langsung",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                subtitle: Text("Panggil nomor telepon biasa", style: GoogleFonts.poppins(fontSize: 11)),
                onTap: () async {
                  Navigator.pop(context);
                  final phoneUrl = Uri.parse("tel:${noHp.replaceAll(RegExp(r'[^0-9+]'), '')}");
                  if (await canLaunchUrl(phoneUrl)) {
                    await launchUrl(phoneUrl);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getPesanan();
  }

  List get dataTampil {
    if (filter == "Order") {
      return pesanan.where((item) {
        final jenis = item["jenis_pesanan"].toString().toLowerCase().trim();
        return jenis == "order" && item["status"] != "Selesai";
      }).toList();
    }

    if (filter == "Pre Order") {
      return pesanan.where((item) {
        final jenis = item["jenis_pesanan"].toString().toLowerCase().trim();
        return jenis == "preorder" && item["status"] != "Selesai";
      }).toList();
    }

    return pesanan.where((item) {
      return item["status"] == "Selesai";
    }).toList();
  }

  int get totalOrder {
    return pesanan.where((item) {
      return item["jenis_pesanan"].toString().toLowerCase().trim() == "order";
    }).length;
  }

  int get totalPreOrder {
    return pesanan.where((item) {
      return item["jenis_pesanan"].toString().toLowerCase().trim() ==
          "preorder";
    }).length;
  }

  int get totalSelesai {
    return pesanan.where((item) {
      return item["status"] == "Selesai";
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          "Pesanan Masuk",
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: getPesanan,
        color: const Color(0xFF0060A9),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Sleek Tab Switcher
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  buildTab("Order"),
                  buildTab("Pre Order"),
                  buildTab("Selesai"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0060A9),
                      ),
                    )
                  : dataTampil.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            filter == "Order"
                                ? "Belum ada Order"
                                : filter == "Pre Order"
                                ? "Belum ada Pre Order"
                                : "Belum ada Pesanan Selesai",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Pesanan baru akan muncul di sini.",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: dataTampil.length,
                      itemBuilder: (context, index) {
                        final item = dataTampil[index];
                        Color warnaStatus;

                        switch (item["status"]) {
                          case "Menunggu":
                          case "Menunggu Konfirmasi":
                            warnaStatus = Colors.orange;
                            break;
                          case "Menunggu Tangkapan":
                            warnaStatus = Colors.deepOrange;
                            break;
                          case "Diproses":
                            warnaStatus = Colors.blue;
                            break;
                          case "Selesai":
                            warnaStatus = Colors.green;
                            break;
                          default:
                            warnaStatus = Colors.grey;
                        }

                        String statusBaru = "";
                        final String currentStatus = item["status"]
                            .toString()
                            .trim();
                        final bool isPreOrder =
                            item["jenis_pesanan"]
                                .toString()
                                .toLowerCase()
                                .trim() ==
                            "preorder";

                        if (isPreOrder) {
                          if (currentStatus == "Menunggu" ||
                              currentStatus == "Menunggu Konfirmasi") {
                            statusBaru = "Menunggu Tangkapan";
                          } else if (currentStatus == "Menunggu Tangkapan") {
                            statusBaru = "Diproses";
                          } else if (currentStatus == "Diproses") {
                            statusBaru = "Selesai";
                          }
                        } else {
                          if (currentStatus == "Menunggu" ||
                              currentStatus == "Menunggu Konfirmasi") {
                            statusBaru = "Diproses";
                          } else if (currentStatus == "Diproses") {
                            statusBaru = "Selesai";
                          }
                        }

                        // Dynamic Fish Display Info
                        String displayNamaIkan = "";
                        double totalKg = 0;
                        final listItems = item["items"] as List?;
                        if (listItems != null && listItems.isNotEmpty) {
                          displayNamaIkan = listItems
                              .map((e) => e["nama_ikan"])
                              .toSet()
                              .join(" + ");
                          for (var element in listItems) {
                            totalKg +=
                                double.tryParse(
                                  element["jumlah_pesan"].toString(),
                                ) ??
                                0;
                          }
                        } else {
                          displayNamaIkan = item["nama_ikan"] ?? "";
                          totalKg =
                              double.tryParse(item["jumlah_kg"].toString()) ??
                              0;
                        }

                        final totalPembayaranVal =
                            double.tryParse(
                              item["total_pembayaran"].toString(),
                            ) ??
                            0;
                        final totalBayar = totalPembayaranVal > 0
                            ? totalPembayaranVal
                            : (double.tryParse(
                                    item["total_harga"].toString(),
                                  ) ??
                                  0);

                        final fotoIkan =
                            (listItems != null && listItems.isNotEmpty)
                            ? listItems[0]["foto_ikan"]
                            : item["foto_ikan"];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        "${Api.baseUrl}/uploads/$fotoIkan",
                                        width: 85,
                                        height: 85,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 85,
                                                height: 85,
                                                color: Colors.grey.shade100,
                                                child: const Icon(
                                                  Icons.image_outlined,
                                                  size: 32,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      item["jenis_pesanan"]
                                                              .toString()
                                                              .toLowerCase()
                                                              .trim() ==
                                                          "preorder"
                                                      ? Colors.orange.shade50
                                                      : const Color(
                                                          0xFF0060A9,
                                                        ).withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  item["jenis_pesanan"]
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        item["jenis_pesanan"]
                                                                .toString()
                                                                .toLowerCase()
                                                                .trim() ==
                                                            "preorder"
                                                        ? Colors.orange.shade700
                                                        : const Color(
                                                            0xFF0060A9,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: warnaStatus
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  item["status"],
                                                  style: GoogleFonts.poppins(
                                                    color: warnaStatus,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            displayNamaIkan,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF2C3E50),
                                            ),
                                          ),
                                          Text(
                                            "Pembeli: ${item["nama_lengkap"] ?? "-"}",
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (item["no_telp"] != null && item["no_telp"].toString().isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            GestureDetector(
                                              onTap: () {
                                                _showContactDialog(
                                                  context,
                                                  item["no_telp"].toString(),
                                                  item["nama_lengkap"] ?? "-",
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone_android,
                                                    size: 13,
                                                    color: Color(0xFF0060A9),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    item["no_telp"].toString(),
                                                    style: GoogleFonts.poppins(
                                                      color: const Color(0xFF0060A9),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.scale_outlined,
                                                    size: 14,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${totalKg.toStringAsFixed(totalKg % 1 == 0 ? 0 : 1)} Kg",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                        0xFF2C3E50,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 16),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.payments_outlined,
                                                    size: 14,
                                                    color: Colors.orange,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    rupiah.format(totalBayar),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                        0xFF0060A9,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF0060A9,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DetailPesananPage(data: item),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Detail",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (item["status"] != "Selesai") ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF0060A9,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 10,
                                            ),
                                          ),
                                          onPressed: () async {
                                            final berhasil =
                                                await UpdateStatusService.updateStatus(
                                                  item["id_pesanan"].toString(),
                                                  statusBaru,
                                                );

                                            if (berhasil) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Status berhasil diubah menjadi $statusBaru",
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              await getPesanan();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                statusBaru,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
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

  Widget buildTab(String title) {
    final bool active = filter == title;
    int total = 0;

    if (title == "Order") {
      total = totalOrder;
    } else if (title == "Pre Order") {
      total = totalPreOrder;
    } else {
      total = totalSelesai;
    }

    Color activeColor = const Color(0xFF0060A9);
    if (title == "Pre Order") {
      activeColor = Colors.orange.shade700;
    } else if (title == "Selesai") {
      activeColor = Colors.green.shade600;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            filter = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: active ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? Colors.white : activeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$total",
                  style: GoogleFonts.poppins(
                    color: active ? activeColor : activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
