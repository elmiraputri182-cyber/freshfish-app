import 'package:appfreshfish/config/api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cart_page.dart';
import 'checkout_page.dart';
import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import 'order sekarang/order_sekarang_page.dart';
import 'pre order/pre_order_page.dart';
import 'package:intl/intl.dart';

class DetailIkanPage extends StatelessWidget {

  final Map ikan;

  const DetailIkanPage({
    super.key,
    required this.ikan,
  });

  Future<void> bukaMaps() async {

    final lat = ikan["latitude"];
    final long = ikan["longitude"];

    final url =
        "https://www.google.com/maps/search/?api=1&query=$lat,$long";

    final uri = Uri.parse(url);

    if(await canLaunchUrl(uri)){

      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8FBFF),

      body: Stack(

        children: [

          SingleChildScrollView(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // FOTO IKAN
                Stack(

                  children: [

                    Container(

                      height: 320,

                      width:
                          double.infinity,

                      decoration:
                          BoxDecoration(

                        image: DecorationImage(

                          image:
                              ikan["foto_ikan"] != null &&
                                      ikan["foto_ikan"] != ""

                                  ? NetworkImage(

                                      "${Api.baseUrl}/uploads/${ikan["foto_ikan"]}",
                                    )

                                  : const AssetImage(
                                          "assets/images/ikan.jpg",
                                        )
                                        as ImageProvider,

                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Container(

                      height: 320,

                      decoration:
                          BoxDecoration(

                        gradient:
                            LinearGradient(

                          begin:
                              Alignment.topCenter,

                          end:
                              Alignment.bottomCenter,

                          colors: [

                            Colors.black
                                .withOpacity(0.2),

                            Colors.black
                                .withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),

                    Positioned(

                      top: 45,
                      left: 20,

                      child: GestureDetector(

                        onTap: () {

                          Navigator.pop(context);
                        },

                        child: Container(

                          padding:
                              const EdgeInsets.all(10),

                          decoration:
                              BoxDecoration(

                            color: Colors.white
                                .withOpacity(0.2),

                            shape:
                                BoxShape.circle,
                          ),

                          child: const Icon(

                            Icons.arrow_back,

                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    Positioned(

                      bottom: 30,
                      left: 25,

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(

                            ikan["nama_ikan"] ?? "-",

                            style:
                                GoogleFonts.poppins(

                              color: Colors.white,

                              fontSize: 28,

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
                            double.parse(
                              ikan["harga"].toString(),
                            ),
                          ),

                          style: GoogleFonts.poppins(

                            color: Colors.white,

                            fontSize: 20,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(

                  padding:
                      const EdgeInsets.all(25),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // STATUS
                      Builder(builder: (context) {
                        final bool ready = (ikan["status_tersedia"] ?? "").toString().toLowerCase() == "ready";
                        final Color statusColor = ready ? const Color(0xff2E7D32) : const Color(0xffEF6C00);
                        final Color bgColor = ready ? const Color(0xffE8F5E9) : const Color(0xffFFF3E0);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                ready ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                color: statusColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                ready ? "Ready Stock" : "Pre Order",
                                style: GoogleFonts.poppins(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 25),

                      // INFO
                      Text(

                        "Informasi Ikan",

                        style:
                            GoogleFonts.poppins(

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),
                      
                      buildInfoRow(
                        Icons.category,
                        "Kategori",
                        ikan["kategori"] ?? "-",
                      ),

                      buildInfoRow(
                        Icons.scale,
                        "Jumlah",
                        "${ikan["jumlah"]} KG",
                      ),

                      buildInfoRow(
                      Icons.person,
                      "Agen",
                      ikan["nama_lengkap"] ?? "-",
                    ),

                    buildInfoRow(
                      Icons.location_on,
                      "Lokasi",
                      ikan["alamat"] ?? "-",
                    ),
                      const SizedBox(height: 30),

                      // DESKRIPSI
                      Text(

                        "Deskripsi",

                        style:
                            GoogleFonts.poppins(

                          fontSize: 20,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(

                        "Ikan segar hasil tangkapan nelayan Bengkalis yang baru tiba dari laut. Kualitas premium dan cocok untuk konsumsi harian maupun usaha seafood.",

                        style:
                            GoogleFonts.poppins(

                          color: Colors.grey,

                          height: 1.7,
                        ),
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TOMBOL BAWAH
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff2E7D32), Color(0xff4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: bukaMaps,
                      icon: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      label: Text(
                        "LIHAT LOKASI",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Builder(builder: (context) {
                  final bool ready = (ikan["status_tersedia"] ?? "").toString().toLowerCase() == "ready";
                  if (ready) {
                    return SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff1565C0), Color(0xff1976D2)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderSekarangPage(ikan: ikan),
                              ),
                            );
                          },
                          child: Text(
                            "ORDER SEKARANG",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffFF9800), Color(0xffF4511E)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PreOrderPage(ikan: ikan),
                              ),
                            );
                          },
                          child: Text(
                            "PRE ORDER",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
                    ],
                  ),

                  floatingActionButton:
                      FloatingActionButton(

                    backgroundColor:
                        Colors.orange,

                    onPressed: () {

                    CartService.tambahKeranjang(

                    CartModel(

                      ikan: Map<String, dynamic>.from(ikan),

                      jumlah: 1,

                    ),

                  );

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) =>
                            const CartPage(),
                      ),
                    );
                  },

                    child: const Icon(

                      Icons.shopping_cart,

                      color: Colors.white,
                    ),
                  ),
                );
              }

              Widget buildInfoRow(
                IconData icon,
                String title,
                dynamic value,
              ) {

                return Padding(

                  padding:
                      const EdgeInsets.only(
                    bottom: 18,
                  ),

                  child: Row(

                    children: [

                      Container(

                        padding:
                            const EdgeInsets.all(12),

                        decoration:
                            BoxDecoration(

                          color: Colors.blue
                              .withOpacity(0.1),

                          borderRadius:
                              BorderRadius.circular(14),
                        ),

                        child: Icon(
                          icon,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(

                            title,

                            style:
                                GoogleFonts.poppins(

                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(

                            value?.toString() ?? "-",

                            style:
                                GoogleFonts.poppins(

                              fontWeight:
                                  FontWeight.w600,

                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            }