import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class ApiService {
  static const String baseUrl = Api.baseUrl;

  // Generic GET request helper
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: $e'
      };
    }
  }

  // Generic POST request helper
  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, String>? headers, Object? body}) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
        body: body,
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: $e'
      };
    }
  }

  // Helper response handler
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {
            'success': true,
            'data': data
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message': 'Format data response tidak valid'
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Gagal terhubung ke server (Status Code: ${response.statusCode})'
      };
    }
  }
}
