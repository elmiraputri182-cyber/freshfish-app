import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final NumberFormat rupiah = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  bool pilihSemua = true;

  @override
  void initState() {
    super.initState();

    for (CartModel item in CartService.cartItems) {
      item.selected = true;
    }
  }

  //====================================
  // TOTAL PRODUK TERPILIH
  //====================================

  int totalDipilih() {
    return CartService.cartItems
        .where((item) => item.selected)
        .length;
  }

  //====================================
  // TOTAL HARGA
  //====================================

  double totalHarga() {
    double total = 0;

    for (CartModel item in CartService.cartItems) {
      if (item.selected) {
        final harga = double.tryParse(
              item.ikan["harga"].toString(),
            ) ??
            0;

        total += harga * item.jumlah;
      }
    }

    return total;
  }

  //====================================
  // PILIH SEMUA
  //====================================

  void pilihSemuaItem(bool value) {
    setState(() {
      pilihSemua = value;

      for (CartModel item in CartService.cartItems) {
        item.selected = value;
      }
    });
  }

  //====================================
  // HAPUS ITEM
  //====================================

  void hapusItem(CartModel item) {
    setState(() {
      CartService.cartItems.remove(item);

      pilihSemua = CartService.cartItems.every(
        (e) => e.selected,
      );
    });
  }

  //====================================
  // CHECKOUT
  //====================================

  Future<void> checkoutSelected() async {
    final pref = await SharedPreferences.getInstance();

    final idUser = pref.getString("id_user");

    if (idUser == null) return;

    List<CartModel> selectedItems =
        CartService.cartItems
            .where((e) => e.selected)
            .toList();

    if (selectedItems.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pilih minimal satu produk",
          ),
        ),
      );

      return;
    }

    for (CartModel item in selectedItems) {
      final ikan = item.ikan;

      final harga = double.tryParse(
            ikan["harga"].toString(),
          ) ??
          0;

      final total = harga * item.jumlah;

      final response = await http.post(
        Uri.parse(
          "${Api.baseUrl}/admin/checkout.php",
        ),
        body: {
          "id_user": idUser,
          "nama_ikan": ikan["nama_ikan"],
          "harga": harga.toString(),
          "jumlah": item.jumlah.toString(),
          "total_harga": total.toString(),
        },
      );

      final json = jsonDecode(response.body);

      if (json["success"] != true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Checkout gagal",
            ),
          ),
        );

        return;
      }
    }

    setState(() {
      CartService.cartItems.removeWhere(
        (e) => e.selected,
      );
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Checkout berhasil",
        ),
      ),
    );
  }
    //==========================================
  // BUILD
  //==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Keranjang",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (CartService.cartItems.isEmpty) return;

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    title: const Text(
                      "Kosongkan Keranjang?",
                    ),
                    content: const Text(
                      "Semua item akan dihapus.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Batal"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            CartService.cartItems.clear();
                          });

                          Navigator.pop(context);
                        },
                        child: const Text("Hapus"),
                      )
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
            ),
          ),
        ],
      ),

      body: CartService.cartItems.isEmpty
          ? buildEmptyCart()
          : Column(
              children: [

                buildHeader(),

                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    physics:
                        const BouncingScrollPhysics(),
                    itemCount:
                        CartService.cartItems.length,
                    itemBuilder:
                        (context, index) {

                      CartModel item =
                          CartService
                              .cartItems[index];

                      return buildItem(item);
                    },
                  ),
                ),

              ],
            ),

      bottomNavigationBar:
          CartService.cartItems.isEmpty
              ? null
              : buildBottomBar(),
    );
  }

  //==========================================
  // EMPTY CART
  //==========================================

  Widget buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: Colors.orange.shade400,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            "Keranjang Masih Kosong",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Tambahkan ikan favoritmu\nke dalam keranjang.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),

        ],
      ),
    );
  }

  //==========================================
  // HEADER
  //==========================================

  Widget buildHeader() {

    return Container(

      color: Colors.white,

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),

      child: Row(

        children: [

          Checkbox(

            value: pilihSemua,

            activeColor: Colors.orange,

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(5),
            ),

            onChanged: (value) {

              pilihSemuaItem(value!);

            },

          ),

          Text(
            "Pilih Semua",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),

          const Spacer(),

          Container(

            padding:
                const EdgeInsets.symmetric(

              horizontal: 14,

              vertical: 8,

            ),

            decoration: BoxDecoration(

              color: Colors.orange.shade50,

              borderRadius:
                  BorderRadius.circular(20),

            ),

            child: Text(

              "${CartService.cartItems.length} Produk",

              style: GoogleFonts.poppins(

                color: Colors.orange,

                fontWeight:
                    FontWeight.w600,

              ),

            ),

          ),

        ],

      ),

    );

  }


Widget buildItem(CartModel item) {
  final ikan = item.ikan;
  final double harga = double.tryParse(ikan["harga"].toString()) ?? 0;
  final bool ready = (ikan["status_tersedia"] ?? "").toString().toLowerCase() == "ready";

  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xffEBF2FF), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade900.withOpacity(.03),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CHECKBOX
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: item.selected,
                activeColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                onChanged: (value) {
                  setState(() {
                    item.selected = value!;
                    pilihSemua = CartService.cartItems.every((e) => e.selected);
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          // FOTO
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              "${Api.baseUrl}/uploads/${ikan["foto_ikan"]}",
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 85,
                  height: 85,
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.image,
                    size: 35,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          // DETAIL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ikan["nama_ikan"] ?? "-",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2C3E50),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: ready ? const Color(0xffE8F5E9) : const Color(0xffFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ready ? "Ready" : "Pre Order",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ready ? const Color(0xff2E7D32) : const Color(0xffEF6C00),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rupiah.format(harga),
                  style: GoogleFonts.poppins(
                    color: Colors.orange.shade700,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // QUANTITY CONTROLS
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (item.jumlah > 1) {
                          setState(() {
                            item.jumlah--;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.remove, size: 16, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${item.jumlah}",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        setState(() {
                          item.jumlah++;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        rupiah.format(harga * item.jumlah),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.orange.shade700,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // DELETE BUTTON
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              hapusItem(item);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

//==========================================
// BOTTOM BAR
//==========================================

Widget buildBottomBar() {

  return SafeArea(

    child: Container(

      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: const BorderRadius.only(

          topLeft: Radius.circular(28),

          topRight: Radius.circular(28),

        ),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(.08),

            blurRadius: 20,

            offset: const Offset(0, -5),

          ),

        ],

      ),

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          //----------------------------------
          // TOTAL
          //----------------------------------

          Row(

            children: [

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      "Total Pembayaran",

                      style: GoogleFonts.poppins(

                        color: Colors.grey,

                        fontSize: 13,

                      ),

                    ),

                    const SizedBox(height: 5),

                    Text(

                      rupiah.format(totalHarga()),

                      style: GoogleFonts.poppins(

                        color: Colors.orange,

                        fontSize: 24,

                        fontWeight:
                            FontWeight.bold,

                      ),

                    ),

                  ],

                ),

              ),

              Container(

                padding:
                    const EdgeInsets.symmetric(

                  horizontal: 14,

                  vertical: 8,

                ),

                decoration: BoxDecoration(

                  color: Colors.orange.shade50,

                  borderRadius:
                      BorderRadius.circular(30),

                ),

                child: Text(

                  "${totalDipilih()} Produk",

                  style: GoogleFonts.poppins(

                    color: Colors.orange,

                    fontWeight:
                        FontWeight.w600,

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 20),

          //----------------------------------
          // BUTTON CHECKOUT
          //----------------------------------

          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: totalDipilih() == 0
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xffFF9800), Color(0xffF4511E)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
              color: totalDipilih() == 0 ? Colors.grey.shade300 : null,
              borderRadius: BorderRadius.circular(18),
              boxShadow: totalDipilih() == 0
                  ? null
                  : [
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
              onPressed: totalDipilih() == 0
                  ? null
                  : () async {
                      bool? lanjut = await showDialog<bool>(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            title: Text(
                              "Konfirmasi",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              "Checkout ${totalDipilih()} produk yang dipilih?",
                              style: GoogleFonts.poppins(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: Text(
                                  "Batal",
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text(
                                  "Checkout",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (lanjut == true) {
                        List<CartModel> selectedItems = CartService.cartItems
                            .where((item) => item.selected)
                            .toList();
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CheckoutPage(
                              items: selectedItems,
                            ),
                          ),
                        );
                        if (res == true && mounted) {
                          setState(() {});
                        }
                      }
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Checkout (${totalDipilih()})",
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

        ],

      ),

    ),

  );

}
}