import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatistikService {

  static const String baseUrl =
      Api.baseUrl;

  static Future<Map<String, dynamic>> getStatistik() async {

    try {

      final pref =
          await SharedPreferences.getInstance();

      final idUser =
          pref.getString("id_user") ?? "";

      final response = await http.get(

        Uri.parse(
          "$baseUrl/get_statistik_agen.php?id_user=$idUser",
        ),

      );

      if (response.statusCode == 200) {

        final hasil =
            jsonDecode(response.body);

        return hasil;

      }

      return {
        "success": false,
        "message": "Gagal mengambil data"
      };

    } catch (e) {

      return {

        "success": false,

        "message": e.toString(),

      };

    }

  }

  static Future<List> getGrafik() async {

    try {

      final pref =
          await SharedPreferences.getInstance();

      final idUser =
          pref.getString("id_user") ?? "";

      final response = await http.get(

        Uri.parse(

          "$baseUrl/get_grafik_pemasukan.php?id_user=$idUser",

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

  static Future<List> getPesanan() async {

    try {

      final pref =
          await SharedPreferences.getInstance();

      final idUser =
          pref.getString("id_user") ?? "";

      final response = await http.get(

        Uri.parse(

          "$baseUrl/get_pemesanan_agen.php?id_user=$idUser",

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

}