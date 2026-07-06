import 'package:appfreshfish/config/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/cart_model.dart';

class CheckoutService {
  static const String baseUrl =
      Api.baseUrl;

  static Future<bool> checkout({
    required String idUser,
    required String metodePengambilan,
    required String metodePembayaran,
    required double totalPembayaran,
    required List<CartModel> items,
  }) async {
    try {
      List<Map<String, dynamic>> dataItems = [];

      for (CartModel item in items) {
        final harga =
            double.tryParse(item.ikan["harga"].toString()) ?? 0;

        dataItems.add({
          "id_ikan": item.ikan["id_ikan"].toString(),
          "id_agen": item.ikan["id_agen"].toString(),
          "nama_ikan": item.ikan["nama_ikan"].toString(),
          "harga": harga,
          "jumlah": item.jumlah,
          "subtotal": harga * item.jumlah,
        });
      }
      
      print("ID USER = $idUser");
      print("TOTAL = $totalPembayaran");
      print("ITEM = ${items.length}");
      final response = await http.post(
        Uri.parse("$baseUrl/pembeli/checkout.php"),
        body: {
          "id_user": idUser,
          "metode_pengambilan": metodePengambilan,
          "metode_pembayaran": metodePembayaran,
          "total_pembayaran": totalPembayaran.toString(),
          "items": jsonEncode(dataItems),
        },
      );

      print("================================");
      print("STATUS : ${response.statusCode}");
      print("BODY   : ${response.body}");
      print("================================");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        return json["success"] == true;
      }

      return false;
    } catch (e) {
      print("CHECKOUT ERROR : $e");
      return false;
    }
  }
}