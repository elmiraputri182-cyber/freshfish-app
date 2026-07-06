import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OperasionalService {

  static const String baseUrl =
      Api.baseUrl;

  ///==============================
  /// GET DATA OPERASIONAL
  ///==============================

  static Future<List> getOperasional() async {

    try {

      final pref =
          await SharedPreferences.getInstance();

      final idUser =
          pref.getString("id_user") ?? "";

      final response =
          await http.get(

        Uri.parse(

          "$baseUrl/get_operasional.php?id_agen=$idUser",

        ),

      );

      if (response.statusCode == 200) {

        final hasil =
            jsonDecode(response.body);

        if (hasil["success"] == true) {

          return hasil["data"];

        }

      }

      return [];

    } catch (e) {

      return [];

    }

  }

  ///==============================
  /// TAMBAH OPERASIONAL
  ///==============================

  static Future<bool> tambahOperasional({

    required String namaNelayan,
    required String status,
    required String tanggalBerangkat,
    required String estimasiKembali,
    required String lokasi,
    required String keterangan,

  }) async {

    try {

      final pref =
          await SharedPreferences.getInstance();

      final idUser =
          pref.getString("id_user") ?? "";

      final response =
          await http.post(

        Uri.parse(

          "$baseUrl/tambah_operasional.php",

        ),

        body: {

          "id_agen": idUser,

          "nama_nelayan": namaNelayan,

          "status": status,

          "tanggal_berangkat": tanggalBerangkat,

          "estimasi_kembali": estimasiKembali,

          "lokasi": lokasi,

          "keterangan": keterangan,

        },

      );

      final hasil =
          jsonDecode(response.body);

      return hasil["success"] == true;

    } catch (e) {

      return false;

    }

  }

  ///==============================
  /// EDIT OPERASIONAL
  ///==============================

  static Future<bool> editOperasional({

    required String idNelayan,
    required String namaNelayan,
    required String status,
    required String tanggalBerangkat,
    required String estimasiKembali,
    required String lokasi,
    required String keterangan,

  }) async {

    try {

      final response =
          await http.post(

        Uri.parse(

          "$baseUrl/edit_operasional.php",

        ),

        body: {

          "id_nelayan": idNelayan,

          "nama_nelayan": namaNelayan,

          "status": status,

          "tanggal_berangkat": tanggalBerangkat,

          "estimasi_kembali": estimasiKembali,

          "lokasi": lokasi,

          "keterangan": keterangan,

        },

      );

      final hasil =
          jsonDecode(response.body);

      return hasil["success"] == true;

    } catch (e) {

      return false;

    }

  }

  ///==============================
  /// HAPUS OPERASIONAL
  ///==============================

  static Future<bool> hapusOperasional(

    String idNelayan,

  ) async {

    try {

      final response =
          await http.post(

        Uri.parse(

          "$baseUrl/hapus_operasional.php",

        ),

        body: {

          "id_nelayan": idNelayan,

        },

      );

      final hasil =
          jsonDecode(response.body);

      return hasil["success"] == true;

    } catch (e) {

      return false;

    }

  }

}