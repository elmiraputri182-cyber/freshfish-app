import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../services/update_status_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPesananPage extends StatefulWidget {
  final Map data;

  const DetailPesananPage({super.key, required this.data});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  final rupiah = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  void _showContactDialog(BuildContext context, String noHp, String nama, {String? idPesanan, String? namaIkan, String? jenisPesanan}) {
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
                  final pref = await SharedPreferences.getInstance();
                  final namaAgen = pref.getString("nama") ?? pref.getString("nama_lengkap") ?? "Agen";
                  
                  final isPreOrder = jenisPesanan?.toLowerCase().replaceAll(' ', '') == "preorder";
                  String message = "";
                  if (isPreOrder) {
                    message = "Halo $nama, kami dari Agen $namaAgen ingin mengonfirmasi pesanan Pre-Order Anda";
                    if (namaIkan != null && namaIkan.isNotEmpty) {
                      message += " ($namaIkan)";
                    }
                    if (idPesanan != null && idPesanan.isNotEmpty) {
                      message += " dengan Kode Pesanan #$idPesanan";
                    }
                    message += ". Kami ingin mengonfirmasi terkait ketersediaan tangkapan ikannya terlebih dahulu.";
                  } else {
                    message = "Halo $nama, kami dari Agen $namaAgen ingin mengonfirmasi pesanan Anda";
                    if (namaIkan != null && namaIkan.isNotEmpty) {
                      message += " ($namaIkan)";
                    }
                    if (idPesanan != null && idPesanan.isNotEmpty) {
                      message += " dengan Kode Pesanan #$idPesanan";
                    }
                    message += ". Mohon ditunggu ya.";
                  }
                  
                  final textEncoded = Uri.encodeComponent(message);
                  final url = Uri.parse("https://wa.me/$formattedPhone?text=$textEncoded");
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint(e.toString());
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
                  try {
                    await launchUrl(phoneUrl);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List detailPesanan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDetailPesanan();
  }

  Future<void> getDetailPesanan() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${Api.baseUrl}/get_detail_pesanan.php?id_pesanan=${widget.data["id_pesanan"]}",
        ),
      );

      final json = jsonDecode(response.body);

      if (json["success"] == true &&
          json["data"] != null &&
          (json["data"] as List).isNotEmpty) {
        setState(() {
          detailPesanan = json["data"];
          isLoading = false;
        });
      } else {
        final listItems = widget.data["items"] as List?;
        if (listItems != null && listItems.isNotEmpty) {
          setState(() {
            detailPesanan = listItems;
            isLoading = false;
          });
        } else {
          setState(() {
            detailPesanan = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      final listItems = widget.data["items"] as List?;
      setState(() {
        detailPesanan = listItems ?? [];
        isLoading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Menunggu":
        return Colors.orange;
      case "Diproses":
        return Colors.blue;
      case "Selesai":
        return Colors.green;
      case "Dibatalkan":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = getStatusColor(widget.data["status"]);

    String displayNamaIkan = "";
    final listItems = widget.data["items"] as List?;
    if (listItems != null && listItems.isNotEmpty) {
      displayNamaIkan = listItems.map((e) => e["nama_ikan"] ?? "").join(" + ");
    } else {
      displayNamaIkan = widget.data["nama_ikan"] ?? "-";
    }

    String fotoIkan = "";
    if ((widget.data["items"] as List?) != null &&
        (widget.data["items"] as List).isNotEmpty) {
      fotoIkan = (widget.data["items"] as List)[0]["foto_ikan"] ?? "";
    } else {
      fotoIkan = widget.data["foto_ikan"] ?? "";
    }

    final bool isActionable =
        widget.data["status"] == "Menunggu" ||
        widget.data["status"] == "Diproses";

    return Scaffold(
      backgroundColor: const Color(0xffF6F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        centerTitle: true,
        title: Text(
          "Detail Pesanan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main Order Card
            Container(
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
                  if (fotoIkan.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: Image.network(
                        "${Api.baseUrl}/uploads/$fotoIkan",
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.image_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.data["status"],
                                style: GoogleFonts.poppins(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.data["jenis_pesanan"]?.toString().toLowerCase().replaceAll(' ', '') == "preorder"
                                    ? Colors.orange.shade50
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.data["jenis_pesanan"]?.toString().toLowerCase().replaceAll(' ', '') == "preorder"
                                    ? "PRE-ORDER"
                                    : "ORDER",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: widget.data["jenis_pesanan"]?.toString().toLowerCase().replaceAll(' ', '') == "preorder"
                                      ? Colors.orange.shade800
                                      : Colors.blue.shade800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          displayNamaIkan,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Sleek spec details
                        detailItem(
                          Icons.person_outline_rounded,
                          Colors.blue,
                          "Pembeli",
                          widget.data["nama_lengkap"] ?? "-",
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            final noHp = widget.data["no_telp"]?.toString();
                            if (noHp != null && noHp.isNotEmpty && noHp != "-") {
                              _showContactDialog(
                                context,
                                noHp,
                                widget.data["nama_lengkap"] ?? "-",
                                idPesanan: widget.data["id_pesanan"]?.toString(),
                                namaIkan: displayNamaIkan,
                                jenisPesanan: widget.data["jenis_pesanan"]?.toString(),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.phone_outlined, color: Colors.purple, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                "No HP:",
                                style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.data["no_telp"] ?? "-",
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: const Color(0xFF0060A9),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        detailItem(
                          Icons.payments_outlined,
                          Colors.green,
                          "Total Pembayaran",
                          rupiah.format(
                            num.tryParse(
                                  widget.data["total_pembayaran"].toString(),
                                ) ??
                                0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        detailItem(
                          Icons.account_balance_wallet_outlined,
                          Colors.indigo,
                          "Metode",
                          widget.data["metode_pembayaran"] ?? "-",
                        ),
                        const SizedBox(height: 8),
                        detailItem(
                          Icons.local_shipping_outlined,
                          Colors.teal,
                          "Pengambilan",
                          widget.data["metode_pengambilan"] ?? "-",
                        ),
                        if (widget.data["jenis_pesanan"]?.toString().toLowerCase().replaceAll(' ', '') == "preorder") ...[
                          const SizedBox(height: 8),
                          detailItem(
                            Icons.calendar_today_outlined,
                            Colors.orange.shade700,
                            "Dibutuhkan",
                            widget.data["tanggal_dibutuhkan"] ?? "-",
                          ),
                        ],
                        if (widget.data["catatan"] != null &&
                            widget.data["catatan"]
                                .toString()
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          detailItem(
                            Icons.notes_outlined,
                            Colors.blueGrey,
                            "Catatan",
                            widget.data["catatan"],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Items List Card
            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Item Pesanan",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF0060A9),
                        ),
                      ),
                    )
                  else if (detailPesanan.isEmpty)
                    Center(
                      child: Text(
                        "Tidak ada detail item",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: detailPesanan.map((item) {
                        final double harga =
                            double.tryParse(
                              (item["harga"] ?? "0").toString(),
                            ) ??
                            0;
                        final double subtotal =
                            double.tryParse(
                              (item["subtotal"] ?? "0").toString(),
                            ) ??
                            0;
                        final String jumlah =
                            (item["jumlah_pesan"] ?? item["jumlah_kg"] ?? "0")
                                .toString();
                        final String fotoItem = item["foto_ikan"] ?? "";
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  "${Api.baseUrl}/uploads/$fotoItem",
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 52,
                                    height: 52,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["nama_ikan"] ?? "-",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: const Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "${rupiah.format(harga)} x $jumlah Kg",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                rupiah.format(subtotal),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            if (isActionable)
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
                  onPressed: () async {
                    String statusBaru = "";
                    if (widget.data["status"] == "Menunggu") {
                      statusBaru = "Diproses";
                    } else if (widget.data["status"] == "Diproses") {
                      statusBaru = "Selesai";
                    } else {
                      return;
                    }

                    bool berhasil = await UpdateStatusService.updateStatus(
                      widget.data["id_pesanan"].toString(),
                      statusBaru,
                    );

                    if (berhasil) {
                      if (!context.mounted) return;
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    widget.data["status"] == "Menunggu"
                        ? "PROSES PESANAN"
                        : "SELESAIKAN PESANAN",
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
    );
  }

  Widget detailItem(IconData icon, Color color, String title, dynamic value) {
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
            value?.toString() ?? "-",
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
