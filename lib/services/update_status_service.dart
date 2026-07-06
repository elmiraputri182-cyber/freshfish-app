import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateStatusService {

  static const String url =
      "${Api.baseUrl}/update_status_pesanan.php";

  static Future<bool> updateStatus(
    String idPesanan,
    String status,
  ) async {

    final response = await http.post(

      Uri.parse(url),

      body: {

        "id_pesanan": idPesanan,
        "status": status,

      },

    );

    print(response.body);

    final hasil = jsonDecode(response.body);

    return hasil["success"] == true;

  }

}