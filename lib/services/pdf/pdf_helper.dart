part of '../pdf_service.dart';

pw.Widget tableHeader(String text, {bool isHeader = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: isHeader ? PdfColors.white : PdfColors.grey800,
      ),
    ),
  );
}

pw.Widget tableCell(
  String text, {
  bool center = false,
  bool alignRight = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),
    child: pw.Align(
      alignment: alignRight
          ? pw.Alignment.centerRight
          : center
              ? pw.Alignment.center
              : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          color: PdfColors.grey800,
        ),
      ),
    ),
  );
}