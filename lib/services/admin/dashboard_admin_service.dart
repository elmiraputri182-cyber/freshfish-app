import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/admin/dashboard_admin_model.dart';

class DashboardAdminService {
  static const String url =
      "http://.16.71.204/appfreashfish/freashfish_api/admin/get_dashboard_admin.php";

  static Future<DashboardAdminModel?> getDashboard() async {

    try {

      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {

        final json = jsonDecode(response.body);

        if (json["success"] == true) {

          return DashboardAdminModel.fromJson(json);

        }

      }

      return null;

    } catch (e) {

      print("Dashboard Admin Error : $e");

      return null;

    }

  }

}