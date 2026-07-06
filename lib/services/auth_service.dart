import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = Api.baseUrl;

  static Future<bool> register(
    String username,
    String password,
    String role,
    String namaLengkap,
    String noTelp,
    String alamat,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register.php"),
        body: {
          "username": username,
          "password": password,
          "role": role,
          "nama_lengkap": namaLengkap,
          "no_telp": noTelp,
          "alamat": alamat,
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Koneksi ke server PHP API timeout. Periksa IP server Anda.");
      });

      print("STATUS CODE = ${response.statusCode}");
      print("RESPONSE = ${response.body}");

      final data = jsonDecode(response.body);
      print("DATA = $data");

      return true;
    } catch (e) {
      print("ERROR REGISTER = $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      print("BASE URL = $baseUrl");
      final url = Uri.parse("$baseUrl/login.php");
      print("URL = $url");

      final response = await http.post(
        url,
        body: {
          "username": username,
          "password": password,
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Koneksi ke server PHP API timeout. Periksa IP server Anda.");
      });

      print("STATUS = ${response.statusCode}");
      print("BODY = ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("ERROR LOGIN = $e");
      return {
        "success": false,
        "message": "Koneksi ke server PHP timeout. Silakan periksa jaringan Wi-Fi Anda."
      };
    }
  }

  static Future<Map<String, dynamic>> loginGoogle(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login_google.php"),
        body: {
          "username": email,
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Koneksi ke server PHP API timeout. Periksa IP server Anda.");
      });
      return jsonDecode(response.body);
    } catch (e) {
      print("ERROR LOGIN GOOGLE = $e");
      return {
        "success": false,
        "message": "Koneksi ke server PHP timeout. Silakan periksa jaringan Wi-Fi Anda."
      };
    }
  }

  static Future<Map<String, dynamic>> registerGoogle({
    required String email,
    required String namaLengkap,
    required String noTelp,
    required String role,
    required String alamat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register_google.php"),
        body: {
          "username": email,
          "nama_lengkap": namaLengkap,
          "no_telp": noTelp,
          "role": role,
          "alamat": alamat,
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Koneksi ke server PHP API timeout. Periksa IP server Anda.");
      });
      return jsonDecode(response.body);
    } catch (e) {
      print("ERROR REGISTER GOOGLE = $e");
      return {
        "success": false,
        "message": "Koneksi ke server PHP timeout. Silakan periksa jaringan Wi-Fi Anda."
      };
    }
  }
}