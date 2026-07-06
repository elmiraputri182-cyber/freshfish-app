import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailPesananAdminPage extends StatefulWidget {

  final Map data;

  const DetailPesananAdminPage({
    super.key,
    required this.data,
  });

  @override
  State<DetailPesananAdminPage> createState() =>
      _DetailPesananAdminPageState();
}

class _DetailPesananAdminPageState
    extends State<DetailPesananAdminPage> {

  final rupiah = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {

    final data = widget.data;

    return Scaffold(

      backgroundColor: const Color(0xffF5F8FF),

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        iconTheme: const IconThemeData(
          color: Color(0xff1565C0),
        ),

        title: Text(

          "Detail Pesanan",

          style: GoogleFonts.poppins(

            color: const Color(0xff1565C0),

            fontWeight: FontWeight.bold,

          ),

        ),

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                gradient: const LinearGradient(

                  colors: [

                    Color(0xff2196F3),

                    Color(0xff42A5F5),

                  ],

                ),

                borderRadius:
                    BorderRadius.circular(24),

              ),

              child: Column(

                children: [

                  const Icon(

                    Icons.receipt_long,

                    size: 55,

                    color: Colors.white,

                  ),

                  const SizedBox(height: 15),

                  Text(

                    data["kode_pesanan"] ?? "-",

                    style: GoogleFonts.poppins(

                      color: Colors.white,

                      fontSize: 22,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height: 8),

                  Text(

                    "Detail Transaksi Pesanan",

                    style: GoogleFonts.poppins(

                      color: Colors.white70,

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 25),
                        //--------------------------------
            // INFORMASI PESANAN
            //--------------------------------

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.circular(22),

                boxShadow: [

                  BoxShadow(

                    color: Colors.black.withOpacity(.05),

                    blurRadius: 10,

                    offset: const Offset(0, 5),

                  ),

                ],

              ),

              child: Column(

                children: [

                  detailItem(

                    Icons.person,

                    "Pembeli",

                    data["nama_pembeli"] ?? "-",

                  ),

                  const Divider(),

                  detailItem(

                    Icons.store,

                    "Agen",

                    data["nama_agen"] ?? "-",

                  ),

                  const Divider(),

                  detailItem(

                    Icons.calendar_today,

                    "Tanggal",

                    data["tanggal_dibutuhkan"] ?? "-",

                  ),

                  const Divider(),

                  Row(

                    children: [

                      const Icon(

                        Icons.info,

                        color: Colors.orange,

                      ),

                      const SizedBox(width: 12),

                      Expanded(

                        child: Text(

                          "Status",

                          style: GoogleFonts.poppins(

                            fontWeight: FontWeight.w600,

                          ),

                        ),

                      ),

                      Container(

                        padding: const EdgeInsets.symmetric(

                          horizontal: 14,

                          vertical: 6,

                        ),

                        decoration: BoxDecoration(

                          color: getStatusColor(

                            data["status"] ?? "",

                          ).withOpacity(.15),

                          borderRadius:

                              BorderRadius.circular(20),

                        ),

                        child: Text(

                          data["status"] ?? "-",

                          style: GoogleFonts.poppins(

                            color: getStatusColor(

                              data["status"] ?? "",

                            ),

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                      ),

                    ],

                  ),

                ],

              ),

            ),

            const SizedBox(height: 20),
                        //--------------------------------
            // INFORMASI PEMBAYARAN
            //--------------------------------

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.circular(22),

                boxShadow: [

                  BoxShadow(

                    color: Colors.black.withOpacity(.05),

                    blurRadius: 10,

                    offset: const Offset(0, 5),

                  ),

                ],

              ),

              child: Column(

                children: [

                  detailItem(

                    Icons.payments,

                    "Total Pembayaran",

                    rupiah.format(

                      num.tryParse(

                        data["total_pembayaran"].toString(),

                      ) ??

                          0,

                    ),

                  ),

                  const Divider(),

                  detailItem(

                    Icons.credit_card,

                    "Metode Pembayaran",

                    data["metode_pembayaran"] ?? "-",

                  ),

                  const Divider(),

                  detailItem(

                    Icons.local_shipping,

                    "Metode Pengambilan",

                    data["metode_pengambilan"] ?? "-",

                  ),

                  const Divider(),

                  detailItem(

                    Icons.shopping_bag,

                    "Jenis Pesanan",

                    data["jenis_pesanan"] ?? "-",

                  ),

                  const Divider(),

                  Row(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Icon(

                        Icons.note_alt,

                        color: Color(0xff1565C0),

                      ),

                      const SizedBox(width: 12),

                      Expanded(

                        child: Text(

                          "Catatan",

                          style: GoogleFonts.poppins(

                            fontWeight: FontWeight.w600,

                          ),

                        ),

                      ),

                      Expanded(

                        flex: 2,

                        child: Text(

                          (data["catatan"] == null ||

                                  data["catatan"]
                                      .toString()
                                      .isEmpty)

                              ? "-"

                              : data["catatan"],

                          textAlign: TextAlign.end,

                          style: GoogleFonts.poppins(),

                        ),

                      ),

                    ],

                  ),

                ],

              ),

            ),

            const SizedBox(height: 20),

            //--------------------------------
            // INFORMASI TAMBAHAN
            //--------------------------------

            Container(

              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius: BorderRadius.circular(22),

                boxShadow: [

                  BoxShadow(

                    color: Colors.black.withOpacity(.05),

                    blurRadius: 10,

                    offset: const Offset(0, 5),

                  ),

                ],

              ),

              child: Column(

                children: [

                  Row(

                    children: [

                      const Icon(

                        Icons.verified,

                        color: Colors.green,

                      ),

                      const SizedBox(width: 10),

                      Expanded(

                        child: Text(

                          "Pesanan ini telah tercatat pada sistem FreshFish.",

                          style: GoogleFonts.poppins(

                            fontSize: 14,

                          ),

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 15),

                  Row(

                    children: [

                      const Icon(

                        Icons.admin_panel_settings,

                        color: Colors.blue,

                      ),

                      const SizedBox(width: 10),

                      Expanded(

                        child: Text(

                          "Admin hanya dapat melihat data transaksi tanpa mengubah status pesanan.",

                          style: GoogleFonts.poppins(

                            fontSize: 13,

                            color: Colors.grey,

                          ),

                        ),

                      ),

                    ],

                  ),

                ],

              ),

            ),

            const SizedBox(height: 25),
                        //--------------------------------
            // BUTTON KEMBALI
            //--------------------------------

            SizedBox(

              width: double.infinity,

              height: 52,

              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(

                  backgroundColor: const Color(0xff1565C0),

                  elevation: 0,

                  shape: RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(16),

                  ),

                ),

                onPressed: () {

                  Navigator.pop(context);

                },

                icon: const Icon(

                  Icons.arrow_back,

                  color: Colors.white,

                ),

                label: Text(

                  "Kembali",

                  style: GoogleFonts.poppins(

                    color: Colors.white,

                    fontWeight: FontWeight.bold,

                    fontSize: 16,

                  ),

                ),

              ),

            ),

            const SizedBox(height: 30),

          ],

        ),

      ),

    );

  }
Widget detailItem(
  IconData icon,
  String title,
  String value,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(
          icon,
          color: const Color(0xff1565C0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(),
          ),
        ),
      ],
    ),
  );
}

Color getStatusColor(String status) {
  switch (status) {
    case "Menunggu":
    case "Menunggu Konfirmasi":
      return Colors.orange;

    case "Diproses":
      return Colors.blue;

    case "Selesai":
      return Colors.green;

    default:
      return Colors.grey;
  }
}
}