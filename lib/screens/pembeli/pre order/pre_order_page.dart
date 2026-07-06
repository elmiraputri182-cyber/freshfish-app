import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';



class PreOrderPage extends StatefulWidget {
  final Map ikan;

  const PreOrderPage({
    super.key,
    required this.ikan,
  });

  @override
  State<PreOrderPage> createState() => _PreOrderPageState();
}

class _PreOrderPageState extends State<PreOrderPage> {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final TextEditingController jumlahKgController =
      TextEditingController();

  final TextEditingController catatanController =
      TextEditingController();

  DateTime? tanggalDibutuhkan;

  String metodePembayaran = "COD";  
  String metodePengambilan = "Ambil di Tempat";
  double totalPembayaran = 0;

  Future<void> kirimPreOrder() async {

  final pref =
      await SharedPreferences.getInstance();

  String idUser =
      pref.getString("id_user") ?? "";

  final response = await http.post(

    Uri.parse(
      "${Api.baseUrl}/pre_order.php",
    ),

    body: {

      "id_user": idUser,

      "id_ikan":
          widget.ikan["id_ikan"].toString(),

      "id_agen":
          widget.ikan["id_agen"].toString(),

      "jumlah_kg":
          jumlahKgController.text,

      "total_harga":
          totalPembayaran.toString(),

      "tanggal_dibutuhkan":
          tanggalDibutuhkan.toString(),

      "metode_pembayaran":
          metodePembayaran,

      "metode_pengambilan":
          metodePengambilan,

      "catatan":
          catatanController.text,
    },
  );
  final data = jsonDecode(response.body);

  if (data["success"] == true) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pre Order berhasil dikirim"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);

  } else {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pre Order gagal"),
        backgroundColor: Colors.red,
      ),
    );
  }
  print(response.body);

  print("BODY = ${response.body}");
}
  Widget _buildMetodePengambilan() {
  return Container(
    padding:
        const EdgeInsets.symmetric(
      horizontal: 16,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(18),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: DropdownButtonFormField(
      value: metodePengambilan,
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      items: const [

        DropdownMenuItem(
          value: "Ambil di Tempat",
          child:
              Text("Ambil di Tempat"),
        ),

        DropdownMenuItem(
          value: "Diantar Agen",
          child:
              Text("Diantar Agen"),
        ),
      ],
      onChanged: (value) {
        setState(() {
          metodePengambilan =
              value.toString();
        });
      },
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: Text(
          "Pre Order",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      
        // FOTO IKAN
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [

              Image.network(
                "${Api.baseUrl}/uploads/${widget.ikan["foto_ikan"]}",
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 90,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      widget.ikan["nama_ikan"],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      "Pre Order",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // INFO IKAN
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                widget.ikan["nama_ikan"],
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                widget.ikan["kategori"] ?? "-",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(
                  double.tryParse(
                    widget.ikan["harga"]
                        .toString(),
                  ) ??
                      0,
                ),
                style: GoogleFonts.poppins(
                  color:
                      Colors.orange.shade700,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildInputField(
          controller:
              jumlahKgController,
          label: "Jumlah (Kg)",
          hintText:
              "Masukkan berat pesanan",
          keyboardType:
              TextInputType.number,
          onChanged: (value) {

            double jumlah =
                double.tryParse(
                      value,
                    ) ??
                    0;

            double harga =
                double.tryParse(
                      widget
                          .ikan["harga"]
                          .toString(),
                    ) ??
                    0;

            setState(() {

              totalPembayaran =
                  jumlah * harga;

            });
          },
        ),

        const SizedBox(height: 16),

        _buildDateCard(context),

        const SizedBox(height: 16),

        _buildMetodePengambilan(),

        const SizedBox(height: 16),

        _buildDropdownField(),

        const SizedBox(height: 16),

        _buildInputField(
          controller:
              catatanController,
          label: "Catatan",
          hintText:
              "Tambahkan catatan pesanan",
          maxLines: 4,
        ),

        const SizedBox(height: 20),

        // TOTAL PEMBAYARAN
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade700,
                Colors.orange.shade400,
              ],
            ),
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Column(
            children: [

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [

                  Text(
                    "Harga / Kg",
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white70,
                    ),
                  ),

                  Text(
                  rupiah.format(
                    num.tryParse(widget.ikan["harga"].toString()) ?? 0,
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [

                  Text(
                    "Jumlah",
                    style:
                        GoogleFonts.poppins(
                      color:
                          Colors.white70,
                    ),
                  ),

                  Text(
                    jumlahKgController
                            .text
                            .isEmpty
                        ? "0 Kg"
                        : "${jumlahKgController.text} Kg",
                    style:
                        GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const Divider(
                color: Colors.white54,
              ),

              Text(
                "TOTAL PEMBAYARAN",
                style:
                    GoogleFonts.poppins(
                  color: Colors.white70,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(
                  totalPembayaran,
                ),
                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                        ),
                        onPressed: kirimPreOrder,
                        child: Text(
                          "KIRIM PRE ORDER",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );              
}



  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  String? hintText,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  Function(String)? onChanged,
}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.orange.shade400),
        ),
      ),
    );
  }

  Widget _buildDateCard(BuildContext context) {
  return GestureDetector(
    onTap: () async {

      final pickedDate = await showDatePicker(

        context: context,

        initialDate:
            tanggalDibutuhkan ??
            DateTime.now(),

        firstDate: DateTime.now(),

        lastDate: DateTime(2030),

        helpText: "Pilih Tanggal Dibutuhkan",

      );

      if (pickedDate != null) {

        setState(() {

          tanggalDibutuhkan =
              pickedDate;

        });

      }
    },

    child: Container(

      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Row(

        children: [

          Container(

            padding:
                const EdgeInsets.all(10),

            decoration: BoxDecoration(

              color:
                  Colors.orange.shade100,

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(

              Icons.calendar_month,

              color:
                  Colors.orange.shade700,

            ),
          ),

          const SizedBox(width: 15),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  "Tanggal Dibutuhkan",

                  style:
                      GoogleFonts.poppins(

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                tanggalDibutuhkan == null
                    ? "Pilih tanggal"
                    : DateFormat(
                        'dd MMMM yyyy',
                        'id_ID',
                      ).format(tanggalDibutuhkan!),

                  style:
                      GoogleFonts.poppins(

                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_drop_down,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDropdownField() {
    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(18)
        ,
        border: Border.all(color: Colors.grey.shade300),

      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: DropdownButtonFormField<String>(
        value: metodePembayaran,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        style: GoogleFonts.poppins(color: Colors.black87),
        items: const [
          DropdownMenuItem(value: "COD", child: Text("COD")),
          DropdownMenuItem(value: "CASH", child: Text("Cash")),
          DropdownMenuItem(value: "MBANKING", child: Text("MBanking / Ewallet")),

        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              metodePembayaran = value;
            });
          }
        },
      ),
    );
  }
}