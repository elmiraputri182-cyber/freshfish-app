part of '../pdf_service.dart';

pw.Widget buildFooter(
  String tanggal,
  int total,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.SizedBox(height: 20),
      pw.Divider(color: PdfColors.grey300, thickness: 1),
      pw.SizedBox(height: 6),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            "Terima kasih atas dedikasi dan kerja sama Anda.",
            style: pw.TextStyle(
              fontSize: 8.5,
              color: PdfColors.grey500,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.Text(
            "TOTAL PENDAPATAN : ${PdfService.rupiah.format(total)}",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
              color: PdfColor.fromHex("#0060A9"),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 35),
      pw.Center(
        child: pw.Text(
          "Dokumen ini sah dan dicetak secara otomatis oleh Sistem Fresh Fish Bengkalis\nWaktu Cetak: $tanggal WIB",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey500,
          ),
        ),
      ),
    ],
  );
}