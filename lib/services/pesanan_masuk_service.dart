import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PesananMasukService {

  static const String baseUrl =
      Api.baseUrl;

  static Future<List> getPesananMasuk(String idAgen) async {

    final response = await http.get(

      Uri.parse(
        "$baseUrl/get_pesanan_masuk_agen.php?id_agen=$idAgen",
      ),

    );

    final hasil = jsonDecode(response.body);

    if (hasil["success"] == true) {
      return hasil["data"];
    }

    return [];
  }
}