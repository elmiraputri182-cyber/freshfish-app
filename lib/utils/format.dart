import 'package:intl/intl.dart';

class Format {

  // ================= FORMAT RUPIAH =================

  static String rupiah(dynamic angka) {

  final format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  return format.format(
    num.tryParse(angka.toString()) ?? 0,
  );

}

  // ================= FORMAT STATUS =================

  static String status(String status) {

    switch (status) {

      case "ready":
        return "Tersedia";

      case "pre_order":
        return "Pre Order";

      case "diproses":
        return "Diproses";

      case "dikirim":
        return "Dikirim";

      case "selesai":
        return "Selesai";

      default:
        return status;
    }
  }
}