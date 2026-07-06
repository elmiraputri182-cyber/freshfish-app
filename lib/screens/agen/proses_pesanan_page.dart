import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProsesPesananPage extends StatefulWidget {
  final Map pesanan;

  const ProsesPesananPage({
    super.key,
    required this.pesanan,
  });

  @override
  State<ProsesPesananPage> createState() =>
      _ProsesPesananPageState();
}

class _ProsesPesananPageState
    extends State<ProsesPesananPage> {

  String estimasi = "1";

  final TextEditingController estimasiManualController =
      TextEditingController();

  bool isLoading = false;

  Future<void> updateStatus() async {

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(
          "${Api.baseUrl}/update_status.php",
        ),

        body: {

          "id_pesanan":
              widget.pesanan["id_pesanan"].toString(),

          "status": "diproses",

          "estimasi_jam":
              estimasiManualController.text.isNotEmpty
                  ? estimasiManualController.text
                  : estimasi,
        },
      );

      final data =
          jsonDecode(response.body);

      if (data["success"] == true) {

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Pesanan berhasil diproses",
            ),
          ),
        );

        Navigator.pop(context, true);

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content: Text(
              data["message"] ??
                  "Gagal memproses pesanan",
            ),
          ),
        );
      }
    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Error : $e",
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F7F7),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        foregroundColor: Colors.black,

        title: const Text(
          "Proses Pesanan",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Container(

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Column(

            children: [

              const SizedBox(height: 10),

              CircleAvatar(
                radius: 35,
                backgroundColor:
                    Colors.grey.shade200,
                child: const Icon(
                  Icons.inventory_2,
                  size: 35,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Estimasi Pengemasan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Berikan estimasi waktu kepada pembeli untuk menyiapkan pesanan ikan segar ini.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "PILIH WAKTU (JAM)",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  pilihanJam("1"),
                  pilihanJam("2"),
                  pilihanJam("3"),
                  pilihanJam("5"),
                ],
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ATAU MASUKKAN MANUAL (JAM)",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    estimasiManualController,
                keyboardType:
                    TextInputType.number,
                decoration: InputDecoration(
                  hintText:
                      "Masukkan angka jam...",
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            12),
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.black87,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
                  ),

                  onPressed: isLoading
                      ? null
                      : updateStatus,

                  child: isLoading

                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )

                      : const Text(
                          "KONFIRMASI & KIRIM NOTIFIKASI",
                          style: TextStyle(
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
      ),
    );
  }

  Widget pilihanJam(String jam) {

    return ChoiceChip(

      label: Text("$jam Jam"),

      selected: estimasi == jam,

      selectedColor:
          Colors.black87,

      labelStyle: TextStyle(

        color:
            estimasi == jam
                ? Colors.white
                : Colors.black,
      ),

      onSelected: (value) {

        setState(() {

          estimasi = jam;

        });
      },
    );
  }
}