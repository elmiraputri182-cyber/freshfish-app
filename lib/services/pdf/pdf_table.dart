part of '../pdf_service.dart';

pw.Widget buildTable(List laporan) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        "DAFTAR TRANSAKSI PENJUALAN",
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey700,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: PdfColors.grey200, width: 0.5),
          outside: const pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
        columnWidths: const {
          0: pw.FixedColumnWidth(25),
          1: pw.FixedColumnWidth(55),
          2: pw.FlexColumnWidth(2.2),
          3: pw.FlexColumnWidth(1.8),
          4: pw.FixedColumnWidth(40),
          5: pw.FlexColumnWidth(1.5),
          6: pw.FixedColumnWidth(80),
        },
        children: [
          // HEADER row
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex("#0060A9"),
            ),
            children: [
              tableHeader("No", isHeader: true),
              tableHeader("Kode", isHeader: true),
              tableHeader("Nama Ikan", isHeader: true),
              tableHeader("Pembeli", isHeader: true),
              tableHeader("Jumlah", isHeader: true),
              tableHeader("Bayar", isHeader: true),
              tableHeader("Total", isHeader: true),
            ],
          ),
          // DATA rows
          ...List.generate(
            laporan.length,
            (index) {
              final item = laporan[index];
              final isEven = index % 2 == 0;
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: isEven ? PdfColors.grey50 : PdfColors.white,
                ),
                children: [
                  tableCell("${index + 1}", center: true),
                  tableCell(item["kode_pesanan"] ?? "-"),
                  tableCell(item["nama_ikan"] ?? "-"),
                  tableCell(item["nama_lengkap"] ?? "-"),
                  tableCell("${item["jumlah_kg"]} Kg", center: true),
                  tableCell(item["metode_pembayaran"] ?? "-"),
                  tableCell(
                    PdfService.rupiah.format(
                      int.tryParse(item["total_harga"].toString()) ?? 0,
                    ),
                    alignRight: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ],
  );
}