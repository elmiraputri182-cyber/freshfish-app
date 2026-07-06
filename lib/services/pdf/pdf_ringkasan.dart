part of '../pdf_service.dart';

pw.Widget buildRingkasan(
  int pesanan,
  int pembeli,
  int kg,
  int pemasukan,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        "RINGKASAN PENDAPATAN & TRANSAKSI",
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 11,
          color: PdfColors.grey700,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          buildSummaryCard("Total Pesanan", "$pesanan Pesanan"),
          pw.SizedBox(width: 8),
          buildSummaryCard("Total Pembeli", "$pembeli Pembeli"),
          pw.SizedBox(width: 8),
          buildSummaryCard("Volume Penjualan", "$kg Kg"),
          pw.SizedBox(width: 8),
          buildSummaryCard("Total Pendapatan", PdfService.rupiah.format(pemasukan)),
        ],
      ),
      pw.SizedBox(height: 25),
    ],
  );
}

pw.Widget buildSummaryCard(String label, String value) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 7.5,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex("#0060A9"),
            ),
          ),
        ],
      ),
    ),
  );
}