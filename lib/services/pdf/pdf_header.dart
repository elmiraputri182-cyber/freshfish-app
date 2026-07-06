part of '../pdf_service.dart';

pw.Widget buildHeader(String namaAgen) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "FRESH FISH",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex("#0060A9"),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                "Laporan Penjualan Resmi Agen",
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                namaAgen.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.Text(
                "Kemitraan Pulau Bengkalis",
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),
      pw.Divider(color: PdfColor.fromHex("#0060A9"), thickness: 2),
      pw.SizedBox(height: 15),
    ],
  );
}