import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PesananService {

  static const String baseUrl =
      Api.baseUrl;

  static Future<bool> tambahPesanan({

    required String idPembeli,
    required String idAgen,
    required String idIkan,
    required String jumlahKg,
    required String metodePengambilan,
    required String metodePembayaran,
    required String totalBayar,

  }) async {

    try {

      final response = await http.post(

        Uri.parse(
          "${Api.baseUrl}/tambah_pemesanan.php",
        ),

        body: {

          "id_user": idPembeli,

          "id_agen": idAgen,

          "id_ikan": idIkan,

          "jumlah_kg": jumlahKg,

          "total_harga": totalBayar,

          "metode_pengambilan":
              metodePengambilan,

          "metode_pembayaran":
              metodePembayaran,
        },
      );

      print("STATUS = ${response.statusCode}");
      print("BODY = ${response.body}");

      final data =
          jsonDecode(response.body);

      return data["success"] == true;

    } catch (e) {

      print(
        "ERROR PESANAN = $e",
      );

      return false;
    }
  }
}