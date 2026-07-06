import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class KeranjangService {

  static const String baseUrl =
      Api.baseUrl;

  /// ==========================
  /// TAMBAH KE KERANJANG
  /// ==========================

  static Future<bool> tambahKeranjang({

    required String idUser,
    required String idIkan,
    required String jumlahKg,
    required String subtotal,

  }) async {

    try {

      final response = await http.post(

        Uri.parse("$baseUrl/tambah_keranjang.php"),

        body: {

          "id_user": idUser,

          "id_ikan": idIkan,

          "jumlah_kg": jumlahKg,

          "subtotal": subtotal,

        },

      );

      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.body}");

      final data = jsonDecode(response.body);

      return data["success"] == true;

    } catch (e) {

      print("ERROR TAMBAH KERANJANG : $e");

      return false;

    }

  }

  /// ==========================
  /// GET KERANJANG
  /// ==========================

  static Future<List> getKeranjang(

    String idUser,

  ) async {

    try {

      final response = await http.get(

        Uri.parse(

          "$baseUrl/get_keranjang.php?id_user=$idUser",

        ),

      );

      print("GET KERANJANG : ${response.body}");

      final data = jsonDecode(response.body);

      if (data["success"] == true) {

        return data["data"];

      }

      return [];

    } catch (e) {

      print("ERROR GET KERANJANG : $e");

      return [];

    }

  }

  /// ==========================
  /// HAPUS ITEM KERANJANG
  /// ==========================

  static Future<bool> hapusKeranjang(

    String idKeranjang,

  ) async {

    try {

      final response = await http.post(

        Uri.parse(

          "$baseUrl/hapus_keranjang.php",

        ),

        body: {

          "id_keranjang": idKeranjang,

        },

      );

      final data = jsonDecode(response.body);

      return data["success"] == true;

    } catch (e) {

      print("ERROR HAPUS : $e");

      return false;

    }

  }

  /// ==========================
  /// CHECKOUT KERANJANG
  /// ==========================

  static Future<bool> checkout({

    required String idUser,

    required String totalHarga,

    required String metodePengambilan,

    required String metodePembayaran,

    required List items,

  }) async {

    try {

      final response = await http.post(

        Uri.parse(

          "$baseUrl/checkout_keranjang.php",

        ),

        body: {

          "id_user": idUser,

          "total_harga": totalHarga,

          "metode_pengambilan": metodePengambilan,

          "metode_pembayaran": metodePembayaran,

          "items": jsonEncode(items),

        },

      );

      print("CHECKOUT : ${response.body}");

      final data = jsonDecode(response.body);

      return data["success"] == true;

    } catch (e) {

      print("ERROR CHECKOUT : $e");

      return false;

    }

  }

}