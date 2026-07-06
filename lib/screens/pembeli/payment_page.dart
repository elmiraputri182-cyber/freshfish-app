import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {

  final int totalBayar;

  const PaymentPage({
    super.key,
    required this.totalBayar,
  });

  @override
  State<PaymentPage> createState() =>
      _PaymentPageState();
}

class _PaymentPageState
    extends State<PaymentPage> {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String metodeTransfer =
      "dana";

  bool isLoading = false;
  String nomorPembayaran = "0812-3456-7890";


  Future<void> _simpanPembayaran() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final idPembeli = pref.getString("id_user") ?? "1";

      final response = await http.post(
        Uri.parse(
          "${Api.baseUrl}/pembeli/tambah_pemesanan.php",
        ),
        body: {
          "id_pembeli": idPembeli,
          "id_user": "1",
          "tanggal_pemesanan": DateTime.now().toString(),
          "metode_pengambilan": "diantar",
          "metode_pembayaran": metodeTransfer,
          "status_pembayaran": "berhasil",
          "total_bayar": widget.totalBayar.toString(),
          "status_pemesanan": "diproses",
        },
      );

      final data = jsonDecode(response.body);

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      if (data["success"] == true) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Pembayaran Berhasil",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Pesanan sedang diproses agen",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "SELESAI",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Pembayaran gagal")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> bayarSekarang() async {
    setState(() {
      isLoading = true;
    });


    // Tunggu beberapa detik untuk user melakukan pembayaran
    await Future.delayed(const Duration(seconds: 3));

    // Tampilkan dialog konfirmasi
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Konfirmasi Pembayaran",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah Anda sudah menyelesaikan pembayaran melalui ${metodeTransfer.toUpperCase()}?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isLoading = false;
              });
            },
            child: Text(
              "Belum",
              style: GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Navigator.pop(context);
              _simpanPembayaran();
            },
            child: Text(
              "Sudah",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8FBFF),

      appBar: AppBar(

        title: Text(

          "Pembayaran",

          style:
              GoogleFonts.poppins(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        backgroundColor:
            Colors.blue,

        foregroundColor:
            Colors.white,
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(25),

        child: Column(

          children: [

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                25,
              ),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                        25),

                boxShadow: [

                  BoxShadow(

                    color: Colors.blue
                        .withOpacity(0.08),

                    blurRadius: 15,

                    offset:
                        const Offset(
                            0, 8),
                  ),
                ],
              ),

              child: Column(

                children: [

                  const Icon(

                    Icons.account_balance_wallet,

                    size: 70,

                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),

                  Text(

                    "Pilih Pembayaran",

                    style:
                        GoogleFonts.poppins(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),

                    decoration:
                        BoxDecoration(

                      color: Colors.blue
                          .withOpacity(0.05),

                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),

                    child:
                        DropdownButton<String>(

                      value:
                          metodeTransfer,

                      isExpanded: true,

                      underline:
                          const SizedBox(),

                      items: const [

                        DropdownMenuItem(
                          value: "dana",
                          child: Text("DANA"),
                        ),

                        DropdownMenuItem(
                          value: "ovo",
                          child: Text("OVO"),
                        ),

                        DropdownMenuItem(
                          value: "bca",
                          child: Text(
                            "M-Banking BCA",
                          ),
                        ),

                        DropdownMenuItem(
                          value: "bri",
                          child: Text(
                            "M-Banking BRI",
                          ),
                        ),
                      ],

                      onChanged: (value){

                        setState(() {

                          metodeTransfer =
                              value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(

                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(
                      18,
                    ),

                    decoration:
                        BoxDecoration(

                      color: Colors.orange
                          .withOpacity(0.1),

                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),

                    child: Column(

                      children: [

                        Text(

                          "Nomor Pembayaran",

                          style:
                              GoogleFonts
                                  .poppins(
                            color:
                                Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(

                          "0812-3456-7890",

                          style:
                              GoogleFonts
                                  .poppins(

                            fontSize: 24,

                            fontWeight:
                                FontWeight.bold,

                            color:
                                Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info, color: Colors.blue, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              "Instruksi Pembayaran",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "1. Klik 'BAYAR SEKARANG'\n2. Aplikasi ${metodeTransfer.toUpperCase()} akan terbuka\n3. Masukkan nomor pembayaran di atas\n4. Konfirmasi pembayaran setelah selesai",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Bayar",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          rupiah.format(
                            num.tryParse(widget.totalBayar.toString()) ?? 0,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                style:
                    ElevatedButton
                        .styleFrom(

                  backgroundColor:
                      Colors.blue,

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),
                ),

                onPressed: bayarSekarang,

                child: isLoading

                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )

                    : Text(

                        "BAYAR SEKARANG",

                        style:
                            GoogleFonts
                                .poppins(

                          color: Colors.white,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}