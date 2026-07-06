class PemesananModel {

  final String idPemesanan;
  final String namaIkan;
  final String jumlahPesan;
  final String totalBayar;

  final String metodePengambilan;
  final String metodePembayaran;

  final String statusPembayaran;
  final String statusPemesanan;

  final String tanggalPemesanan;

  PemesananModel({
    required this.idPemesanan,
    required this.namaIkan,
    required this.jumlahPesan,
    required this.totalBayar,
    required this.metodePengambilan,
    required this.metodePembayaran,
    required this.statusPembayaran,
    required this.statusPemesanan,
    required this.tanggalPemesanan,
  });

  factory PemesananModel.fromJson(
      Map<String, dynamic> json) {

    return PemesananModel(
      idPemesanan: json['id_pemesanan'],
      namaIkan: json['nama_ikan'],
      jumlahPesan: json['jumlah_pesan'],
      totalBayar: json['total_bayar'],

      metodePengambilan:
      json['metode_pengambilan'],

      metodePembayaran:
      json['metode_pembayaran'],

      statusPembayaran:
      json['status_pembayaran'],

      statusPemesanan:
      json['status_pemesanan'],

      tanggalPemesanan:
      json['tanggal_pemesanan'],
    );
  }
}