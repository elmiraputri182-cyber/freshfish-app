import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AdminService {

  static const String baseUrl =
      Api.baseUrl;

  static Future<Map<String, dynamic>> getDashboard() async {

    try {

      final response = await http.get(

        Uri.parse(

          "$baseUrl/get_dashboard_admin.php",

        ),

      );

      if (response.statusCode == 200) {

        return jsonDecode(response.body);

      }

      return {

        "success": false,

      };

    } catch (e) {

      return {

        "success": false,

      };

    }

  }

}