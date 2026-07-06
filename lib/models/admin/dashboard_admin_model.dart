class DashboardAdminModel {

  final int totalPembeli;
  final int totalAgen;
  final int totalIkan;
  final int totalPesanan;
  final double totalPendapatan;

  DashboardAdminModel({

    required this.totalPembeli,
    required this.totalAgen,
    required this.totalIkan,
    required this.totalPesanan,
    required this.totalPendapatan,

  });

  factory DashboardAdminModel.fromJson(
      Map<String, dynamic> json) {

    return DashboardAdminModel(

      totalPembeli:
          int.tryParse(json["total_pembeli"].toString()) ?? 0,

      totalAgen:
          int.tryParse(json["total_agen"].toString()) ?? 0,

      totalIkan:
          int.tryParse(json["total_ikan"].toString()) ?? 0,

      totalPesanan:
          int.tryParse(json["total_pesanan"].toString()) ?? 0,

      totalPendapatan:
          double.tryParse(json["total_pendapatan"].toString()) ?? 0,

    );

  }

}