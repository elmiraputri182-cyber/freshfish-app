import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ikan_model.dart';

class IkanService {

  static const String baseUrl =
      Api.baseUrl;

  static Future<List<IkanModel>> getIkan() async {

    final response = await http.get(
      Uri.parse("$baseUrl/get_ikan.php"),
    );

    final List data = jsonDecode(response.body);

    return data.map((e) {
      return IkanModel.fromJson(e);
    }).toList();

  }
}