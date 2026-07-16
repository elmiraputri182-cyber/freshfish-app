import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class InvoicePesananPage extends StatelessWidget {
  final Map data;

  const InvoicePesananPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final rupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Extracting fields matching your screenshot
    final idPesanan = data["id_pesanan"]?.toString() ?? "-";
    final tanggal = data["tanggal"]?.toString() ?? "-";
    final namaPembeli = data["nama_pembeli"] ?? data["nama_lengkap"] ?? "-";
    final namaAgen = data["nama_agen"] ?? "Agen";
    final metodePembayaran = data["metode_pembayaran"]?.toString().toUpperCase() ?? "CASH";
    final metodePengambilan = data["metode_pengambilan"]?.toString().toUpperCase() ?? "COD";
    final status = data["status"] ?? "-";

    final listItems = data["items"] as List? ?? [];
    double totalHarga = double.tryParse(data["total_pembayaran"]?.toString() ?? "") ?? 
                         double.tryParse(data["total_harga"]?.toString() ?? "") ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xffF6F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        centerTitle: true,
        title: Text(
          "Invoice Pesanan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Header Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0080FF), Color(0xFF0060A9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0060A9).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FRESH FISH",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Invoice #$idPesanan",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tanggal,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Details info card
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
                children: [
                  _buildDetailRow(Icons.person_outline_rounded, "Nama Pembeli", namaPembeli),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.storefront_outlined, "Agen Penjual", namaAgen),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.payment_outlined, "Metode Pembayaran", metodePembayaran),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.local_shipping_outlined, "Metode Pengambilan", metodePengambilan),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.info_outline_rounded, "Status", status, isStatus: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Item details list header
            Text(
              "Rincian Item",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),

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
                  // List items loop
                  if (listItems.isNotEmpty)
                    ...listItems.map((item) {
                      final name = item["nama_ikan"] ?? "-";
                      final price = double.tryParse(item["harga"].toString()) ?? 0;
                      final kg = double.tryParse(item["jumlah_pesan"]?.toString() ?? item["jumlah_kg"]?.toString() ?? "0") ?? 0;
                      final itemTotal = double.tryParse(item["subtotal"]?.toString() ?? item["total_harga"]?.toString() ?? "0") ?? (price * kg);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    "${kg.toStringAsFixed(0)} Kg x ${rupiah.format(price).replaceAll('Rp ', '')}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              rupiah.format(itemTotal),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                  else
                    // Fallback for single item (legacy payload format)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["nama_ikan"] ?? "-",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                                Text(
                                  "${data["jumlah_kg"] ?? 0} Kg x ${rupiah.format(double.tryParse(data["harga"].toString()) ?? 0).replaceAll('Rp ', '')}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            rupiah.format(double.tryParse(data["total_harga"].toString()) ?? 0),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Divider(height: 24),
                  
                  // Total line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TOTAL",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        rupiah.format(totalHarga),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF0060A9),
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

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isStatus = false}) {
    Color? valueColor = const Color(0xFF2C3E50);
    FontWeight valueWeight = FontWeight.bold;
    if (isStatus) {
      if (value == "Selesai") {
        valueColor = Colors.green;
      } else if (value == "Dibatalkan") {
        valueColor = Colors.red;
      } else {
        valueColor = Colors.orange.shade800;
      }
    }

    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0060A9)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.end,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: valueColor,
            fontWeight: valueWeight,
          ),
        ),
      ],
    );
  }
}
