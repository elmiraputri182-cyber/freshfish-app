import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class PemesananService {

  // ================= BUAT PESANAN =================

  static Future tambahPemesanan(
      String idPembeli,
      String idUser,
      String metodePengambilan,
      String metodePembayaran,
      String totalBayar,
      ) async {

    var url = Uri.parse(
      "${Api.baseUrl}/tambah_pemesanan.php",
    );

    var response = await http.post(
      url,
      body: {
        "id_pembeli": idPembeli,
        "id_user": idUser,
        "metode_pengambilan":
        metodePengambilan,

        "metode_pembayaran":
        metodePembayaran,

        "total_bayar": totalBayar,
      },
    );

    return jsonDecode(response.body);
  }

  // ================= GET PEMESANAN =================

  static Future getPemesanan() async {

    var url = Uri.parse(
      "${Api.baseUrl}/get_pemesanan.php",
    );

    var response = await http.get(url);

    return jsonDecode(response.body);
  }

  // ================= UPLOAD BUKTI =================

  static Future uploadBukti(
      String idPemesanan,
      String buktiPembayaran,
      ) async {

    var url = Uri.parse(
      "${Api.baseUrl}/upload_bukti.php",
    );

    var response = await http.post(
      url,
      body: {
        "id_pemesanan": idPemesanan,
        "bukti_pembayaran":
        buktiPembayaran,
      },
    );

    return jsonDecode(response.body);
  }

  // ================= UPDATE STATUS =================

  static Future updateStatus(
      String idPemesanan,
      String statusPemesanan,
      ) async {

    var url = Uri.parse(
      "${Api.baseUrl}/update_status.php",
    );

    var response = await http.post(
      url,
      body: {
        "id_pemesanan": idPemesanan,
        "status_pemesanan":
        statusPemesanan,
      },
    );

    return jsonDecode(response.body);
  }
}