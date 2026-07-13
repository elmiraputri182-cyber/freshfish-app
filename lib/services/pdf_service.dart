import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'pdf/pdf_header.dart';
part 'pdf/pdf_info.dart';
part 'pdf/pdf_ringkasan.dart';
part 'pdf/pdf_table.dart';
part 'pdf/pdf_footer.dart';
part 'pdf/pdf_helper.dart';

class PdfService {
  static final NumberFormat rupiah = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  static Future<void> cetakLaporan({
    required List laporan,
    required int totalPesanan,
    required int totalPemasukan,
    required int totalKg,
    required int totalPembeli,
    required String filter,
  }) async {
    final pdf = pw.Document();

    final pref = await SharedPreferences.getInstance();
    final namaAgen = pref.getString("nama") ?? pref.getString("nama_lengkap") ?? "Agen";

    final sekarang = DateFormat(
      "dd MMMM yyyy HH:mm",
      "id_ID",
    ).format(DateTime.now());

    final displayFilter = filter[0].toUpperCase() + filter.substring(1).toLowerCase();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          buildHeader(namaAgen),
          buildInfo(sekarang, displayFilter),
          buildRingkasan(
            totalPesanan,
            totalPembeli,
            totalKg,
            totalPemasukan,
          ),
          ...buildTable(laporan),
          buildFooter(sekarang, totalPemasukan),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "$namaAgen - Laporan Penjualan $displayFilter",
    );
  }
}