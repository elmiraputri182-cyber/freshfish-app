import 'package:appfreshfish/config/api.dart';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StatistikAgenPage extends StatefulWidget {
  const StatistikAgenPage({super.key});

  @override
  State<StatistikAgenPage> createState() => _StatistikAgenPageState();
}

class _StatistikAgenPageState extends State<StatistikAgenPage> {
  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool isLoading = true;

  int totalPesanan = 0;
  int totalNelayan = 0;
  int totalStok = 0;
  int totalJenisIkan = 0;
  int totalPemasukan = 0;

  int pesananMenunggu = 0;
  int pesananDiproses = 0;
  int pesananSelesai = 0;

  List grafikPemasukan = [];

  @override
  void initState() {
    super.initState();
    loadStatistik();
  }

  Future<void> loadStatistik() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final idUser = pref.getString("id_user") ?? "";

      final statistikResponse = await http.get(
        Uri.parse("${Api.baseUrl}/get_statistik_agen.php?id_user=$idUser"),
      );

      if (statistikResponse.statusCode == 200) {
        final statistik = jsonDecode(statistikResponse.body);

        if (statistik["success"] == true) {
          totalPesanan =
              int.tryParse(statistik["total_pesanan"].toString()) ?? 0;
          pesananSelesai =
              int.tryParse(statistik["pesanan_selesai"].toString()) ?? 0;
          pesananDiproses =
              int.tryParse(statistik["pesanan_diproses"].toString()) ?? 0;
          pesananMenunggu =
              int.tryParse(statistik["pesanan_menunggu"].toString()) ?? 0;
          totalPemasukan =
              (num.tryParse(statistik["total_pemasukan"].toString()) ?? 0)
                  .toInt();
          totalStok = int.tryParse(statistik["total_stok"].toString()) ?? 0;
          totalJenisIkan =
              int.tryParse(statistik["total_jenis"].toString()) ?? 0;
          totalNelayan =
              int.tryParse(statistik["total_nelayan"].toString()) ?? 0;
        }
      }

      final grafikResponse = await http.get(
        Uri.parse("${Api.baseUrl}/get_grafik_pemasukan.php?id_user=$idUser"),
      );

      if (grafikResponse.statusCode == 200) {
        final grafik = jsonDecode(grafikResponse.body);

        if (grafik["success"] == true) {
          grafikPemasukan = grafik["data"] ?? [];
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xffF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0060A9)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        foregroundColor: const Color(0xFF2C3E50),
        title: Text(
          "Statistik Penjualan",
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadStatistik,
        color: const Color(0xFF0060A9),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ringkasan Penjualan",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: buildStatisticCard(
                      title: "Total Pesanan",
                      value: "$totalPesanan",
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xFF0060A9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildStatisticCard(
                      title: "Total Pemasukan",
                      value: rupiah.format(totalPemasukan),
                      icon: Icons.payments_outlined,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: buildStatisticCard(
                      title: "Stok Ikan",
                      value: "$totalStok",
                      icon: Icons.set_meal_outlined,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildStatisticCard(
                      title: "Jenis Ikan",
                      value: "$totalJenisIkan",
                      icon: Icons.category_outlined,
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Grafik Pemasukan Container
              Text(
                "Grafik Pemasukan",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: buildGrafikPemasukan(),
              ),
              const SizedBox(height: 24),

              // Aktivitas Pesanan
              Text(
                "Aktivitas Pesanan",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    buildDetailRow(
                      "Pesanan Menunggu",
                      "$pesananMenunggu",
                      Colors.orange.shade700,
                    ),
                    const SizedBox(height: 12),
                    buildDetailRow(
                      "Pesanan Diproses",
                      "$pesananDiproses",
                      const Color(0xFF0060A9),
                    ),
                    const SizedBox(height: 12),
                    buildDetailRow(
                      "Pesanan Selesai",
                      "$pesananSelesai",
                      Colors.green.shade600,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Progress Penyelesaian
              Text(
                "Progress Penyelesaian",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tingkat Penyelesaian",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${((pesananSelesai / (totalPesanan == 0 ? 1 : totalPesanan)) * 100).toStringAsFixed(1)}%",
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade600,
                            ),
                            value: totalPesanan == 0
                                ? 0
                                : pesananSelesai / totalPesanan,
                          ),
                        ),
                        Text(
                          "$pesananSelesai/$totalPesanan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ringkasan Keuangan
              Text(
                "Ringkasan Keuangan",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    buildDetailRow(
                      "Total Pemasukan",
                      rupiah.format(totalPemasukan),
                      Colors.green.shade600,
                    ),
                    const SizedBox(height: 12),
                    buildDetailRow(
                      "Rata-rata Transaksi",
                      rupiah.format(
                        totalPesanan == 0
                            ? 0
                            : (totalPemasukan ~/ totalPesanan),
                      ),
                      const Color(0xFF0060A9),
                    ),
                    const SizedBox(height: 12),
                    buildDetailRow(
                      "Total Nelayan Mitra",
                      "$totalNelayan",
                      Colors.purple.shade600,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGrafikPemasukan() {
    if (grafikPemasukan.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 50,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                "Belum ada data pemasukan",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Data akan muncul setelah pesanan diselesaikan",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    double totalCash = 0;
    double totalMbanking = 0;
    for (var item in grafikPemasukan) {
      totalCash += (num.tryParse(item["cash"].toString()) ?? 0).toDouble();
      totalMbanking += (num.tryParse(item["mbanking"].toString()) ?? 0)
          .toDouble();
    }

    double maxVal = 0;
    for (var e in grafikPemasukan) {
      double cash = (num.tryParse(e["cash"].toString()) ?? 0).toDouble();
      double mbank = (num.tryParse(e["mbanking"].toString()) ?? 0).toDouble();
      if (cash > maxVal) maxVal = cash;
      if (mbank > maxVal) maxVal = mbank;
    }
    if (maxVal == 0) maxVal = 100000;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.money_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Cash / COD",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        rupiah.format(totalCash.toInt()),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0060A9), Color(0xFF2196F3)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "M-Banking",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        rupiah.format(totalMbanking.toInt()),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal * 1.3,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String label = rodIndex == 0 ? "Cash" : "M-Banking";
                    return BarTooltipItem(
                      "$label\n",
                      GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      children: [
                        TextSpan(
                          text: rupiah.format(rod.toY.toInt()),
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxVal / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    interval: maxVal / 4,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox();
                      String formatted = "";
                      if (value >= 1000000) {
                        formatted = "${(value / 1000000).toStringAsFixed(1)}Jt";
                      } else if (value >= 1000) {
                        formatted = "${(value / 1000).toStringAsFixed(0)}K";
                      } else {
                        formatted = value.toStringAsFixed(0);
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(
                          formatted,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= grafikPemasukan.length) {
                        return const SizedBox();
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 8,
                        child: Text(
                          grafikPemasukan[index]["bulan"],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(grafikPemasukan.length, (index) {
                final cashVal =
                    (num.tryParse(grafikPemasukan[index]["cash"].toString()) ??
                            0)
                        .toDouble();
                final mbankVal =
                    (num.tryParse(
                              grafikPemasukan[index]["mbanking"].toString(),
                            ) ??
                            0)
                        .toDouble();

                return BarChartGroupData(
                  x: index,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: cashVal,
                      width: 12,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFFC8E6C9)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxVal * 1.3,
                        color: Colors.grey.shade50,
                      ),
                    ),
                    BarChartRodData(
                      toY: mbankVal,
                      width: 12,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0060A9), Color(0xFFBBDEFB)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxVal * 1.3,
                        color: Colors.grey.shade50,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(const Color(0xFF4CAF50), "Cash / COD"),
            const SizedBox(width: 20),
            _legendItem(const Color(0xFF0060A9), "M-Banking / E-Wallet"),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
