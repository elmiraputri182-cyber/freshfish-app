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

  static Future<void> cetakInvoice({
    required Map data,
    required List items,
  }) async {
    final pdf = pw.Document();

    final sekarang = DateFormat(
      "dd MMMM yyyy HH:mm",
      "id_ID",
    ).format(DateTime.now());

    double totalHarga = double.tryParse(data["total_pembayaran"]?.toString() ?? "") ?? 
                         double.tryParse(data["total_harga"]?.toString() ?? "") ?? 0;

    final idPesanan = data["id_pesanan"]?.toString() ?? "-";
    final tanggal = data["tanggal"]?.toString() ?? "-";
    final namaPembeli = data["nama_pembeli"] ?? data["nama_lengkap"] ?? "-";
    final namaAgen = data["nama_agen"] ?? "-";
    final metodePembayaran = data["metode_pembayaran"]?.toString().toUpperCase() ?? "CASH";
    final metodePengambilan = data["metode_pengambilan"]?.toString().toUpperCase() ?? "COD";
    final String jenisPesanan = data["jenis_pesanan"]?.toString().toLowerCase().trim() ?? "order";
    final bool isPreOrder = jenisPesanan == "preorder" || jenisPesanan == "pre order";
    final tglDibutuhkan = data["tanggal_dibutuhkan"]?.toString() ?? "-";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Toko
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "FRESH FISH BENGKALIS",
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      isPreOrder ? "*** STRUK PRE-ORDER ***" : "Segar & Langsung Dari Nelayan",
                      style: pw.TextStyle(fontSize: 8, fontWeight: isPreOrder ? pw.FontWeight.bold : pw.FontWeight.normal),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      "Bengkalis, Riau",
                      style: const pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 6),
              pw.Text("------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 4),

              // Metadata Transaksi
              pw.Text("No. Invoice : #$idPesanan", style: const pw.TextStyle(fontSize: 8)),
              pw.Text("Tanggal     : $tanggal", style: const pw.TextStyle(fontSize: 8)),
              pw.Text("Metode      : ${isPreOrder ? "Pre-Order" : "Beli Langsung"}", style: const pw.TextStyle(fontSize: 8)),
              if (isPreOrder)
                pw.Text("Est. Butuh  : $tglDibutuhkan", style: const pw.TextStyle(fontSize: 8)),
              pw.Text("Pembeli     : $namaPembeli", style: const pw.TextStyle(fontSize: 8)),
              pw.Text("Agen        : $namaAgen", style: const pw.TextStyle(fontSize: 8)),
              pw.Text("Bayar/Ambil : $metodePembayaran / $metodePengambilan", style: const pw.TextStyle(fontSize: 8)),
              
              pw.SizedBox(height: 4),
              pw.Text("------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 6),

              // Daftar Item Belanja
              pw.Text(isPreOrder ? "DAFTAR PRE-ORDER:" : "DAFTAR BELANJA:", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),

              ...List.generate(items.length, (index) {
                final item = items[index];
                final String nama = item["nama_ikan"] ?? "-";
                final double qty = double.tryParse((item["jumlah_pesan"] ?? item["jumlah"] ?? "0").toString()) ?? 0;
                final double harga = double.tryParse(item["harga"].toString()) ?? 0;
                final double sub = double.tryParse(item["subtotal"].toString()) ?? (harga * qty);

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        nama,
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "${qty.toStringAsFixed(0)} Kg x ${rupiah.format(harga).replaceAll('Rp ', '')}",
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          pw.Text(
                            rupiah.format(sub).replaceAll('Rp ', ''),
                            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 4),
              pw.Text("------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 6),

              // Total Belanja
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TOTAL BELANJA",
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    rupiah.format(totalHarga),
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              pw.SizedBox(height: 6),
              pw.Text("------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: 8),

              if (isPreOrder) ...[
                pw.Center(
                  child: pw.Container(
                    width: 150,
                    child: pw.Text(
                      "Catatan: Ini adalah pesanan Pre-Order. Agen akan menghubungi Anda untuk konfirmasi ketersediaan tangkapan sebelum diproses.",
                      style: pw.TextStyle(fontSize: 6, fontStyle: pw.FontStyle.italic),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text("------------------------------------------", style: const pw.TextStyle(fontSize: 8)),
                pw.SizedBox(height: 8),
              ],

              // Footer
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "TERIMA KASIH",
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      isPreOrder ? "Sudah Melakukan Pre-Order!" : "Sudah Berbelanja di Toko Kami!",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Dicetak pada: $sekarang",
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "Struk-Invoice-$idPesanan",
    );
  }

  static Future<void> cetakLaporanAdmin({
    required List rekapAgen,
    required int totalPembeli,
    required int totalAgen,
    required int totalPesanan,
    required double totalPendapatan,
    required int menunggu,
    required int diproses,
    required int selesai,
  }) async {
    final pdf = pw.Document();

    final sekarang = DateFormat(
      "dd MMMM yyyy HH:mm",
      "id_ID",
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "FRESH FISH BENGKALIS",
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex("#0060A9"),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Laporan Ringkasan Performa & Statistik Penjualan Sistem",
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(thickness: 2, color: PdfColor.fromHex("#E5E7EB")),
          pw.SizedBox(height: 16),

          // Info Ringkasan
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Dicetak pada: $sekarang", style: const pw.TextStyle(fontSize: 10)),
              pw.Text("Role Pencetak: Administrator", style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 20),

          // Metrik Ringkasan Box
          pw.Text(
            "Ringkasan Performa Sistem",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.GridView(
            crossAxisCount: 2,
            childAspectRatio: 0.25,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex("#E5E7EB")),
                  color: PdfColor.fromHex("#F9FAFB"),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Total Pendapatan", style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text(rupiah.format(totalPendapatan), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex("#10B981"))),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex("#E5E7EB")),
                  color: PdfColor.fromHex("#F9FAFB"),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Total Pesanan Selesai", style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text("$selesai Pesanan", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex("#0060A9"))),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex("#E5E7EB")),
                  color: PdfColor.fromHex("#F9FAFB"),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Total Mitra Agen", style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text("$totalAgen Agen", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex("#E5E7EB")),
                  color: PdfColor.fromHex("#F9FAFB"),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Total Pengguna Pembeli", style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 4),
                    pw.Text("$totalPembeli Pembeli", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Tabel Kontribusi per Agen
          pw.Text(
            "Tabel Kontribusi Penjualan per Agen",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex("#E5E7EB"), width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(40),
              1: const pw.FlexColumnWidth(),
              2: const pw.FixedColumnWidth(150),
              3: const pw.FixedColumnWidth(150),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex("#F3F4F6")),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("No", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Nama Agen", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Jumlah Pesanan Selesai", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.center),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text("Total Pemasukan", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10), textAlign: pw.TextAlign.right),
                  ),
                ],
              ),
              // Body
              ...List.generate(rekapAgen.length, (index) {
                final item = rekapAgen[index];
                final String nama = item["nama_agen"] ?? "-";
                final String pesanan = item["total_pesanan"].toString();
                final double pemasukan = double.tryParse(item["total_pemasukan"].toString()) ?? 0;

                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text("${index + 1}", style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(nama, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(pesanan, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(rupiah.format(pemasukan), style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                    ),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 24),

          // Footer
          pw.Divider(thickness: 1, color: PdfColor.fromHex("#E5E7EB")),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              "Laporan ini sah dan dicetak secara elektronik oleh platform Fresh Fish.",
              style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: PdfColor.fromHex("#6B7280")),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "Laporan Performa Admin $sekarang",
    );
  }
}