import 'package:appfreshfish/config/api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/checkout_service.dart';
import '../../services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cart_model.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartModel> items;

  const CheckoutPage({super.key, required this.items});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final NumberFormat rupiah = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  String metodePengambilan = "cod";
  String metodePembayaran = "cod";
  bool isLoading = false;

  double totalBayar() {
    double total = 0;
    for (CartModel item in widget.items) {
      final harga = double.tryParse(item.ikan["harga"].toString()) ?? 0;
      total += harga * item.jumlah;
    }
    return total;
  }

  int totalItem() {
    int total = 0;
    for (CartModel item in widget.items) {
      total += item.jumlah;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          "Checkout",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title: Produk Dipilih
            Text(
              "Produk Dipilih",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),

            // List of selected items
            Column(
              children: widget.items.map((item) {
                final ikan = item.ikan;
                final double harga =
                    double.tryParse(ikan["harga"].toString()) ?? 0;
                final double subtotal = harga * item.jumlah;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
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
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          "${Api.baseUrl}/uploads/${ikan["foto_ikan"]}",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade100,
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ikan["nama_ikan"],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${rupiah.format(harga)} /Kg",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0060A9,
                                    ).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${item.jumlah} Kg",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF0060A9),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Text(
                                  rupiah.format(subtotal),
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF0060A9),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Section: Metode Pengambilan
            Text(
              "Metode Pengambilan",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Container(
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
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: "cod",
                    groupValue: metodePengambilan,
                    activeColor: const Color(0xFF0060A9),
                    title: Text(
                      "COD (Diantar)",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    subtitle: Text(
                      "Pesanan akan diantarkan langsung ke alamat Anda",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        metodePengambilan = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: "ambil",
                    groupValue: metodePengambilan,
                    activeColor: const Color(0xFF0060A9),
                    title: Text(
                      "Ambil di Tempat",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    subtitle: Text(
                      "Datang dan ambil langsung ke lokasi Agen",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        metodePengambilan = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section: Metode Pembayaran
            Text(
              "Metode Pembayaran",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              child: DropdownButtonFormField<String>(
                value: metodePembayaran,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF0060A9),
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                items: const [
                  DropdownMenuItem(
                    value: "cod",
                    child: Text("Bayar di Tempat (COD)"),
                  ),
                  DropdownMenuItem(value: "cash", child: Text("Tunai / Cash")),
                  DropdownMenuItem(
                    value: "mbanking",
                    child: Text("Transfer Bank / E-Wallet"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    metodePembayaran = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Section: Ringkasan Belanja
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Jumlah Produk",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "${widget.items.length}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Berat",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "${totalItem()} Kg",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Pembayaran",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        rupiah.format(totalBayar()),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0060A9),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Button: Buat Pesanan
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0060A9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        final prefs = await SharedPreferences.getInstance();
                        String idUser = prefs.getString("id_user") ?? "";

                        final berhasil = await CheckoutService.checkout(
                          idUser: idUser,
                          metodePengambilan: metodePengambilan,
                          metodePembayaran: metodePembayaran,
                          totalPembayaran: totalBayar(),
                          items: widget.items,
                        );
                        setState(() => isLoading = false);

                        if (berhasil) {
                          CartService.cartItems.removeWhere(
                            (item) => widget.items.contains(item),
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Checkout berhasil"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop(true);
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Checkout gagal"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Buat Pesanan Sekarang",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
