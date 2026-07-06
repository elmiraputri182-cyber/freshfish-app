class IkanModel {

  final String id;
  final String nama;
  final String kategori;
  final String jumlah;
  final String harga;
  final String status;

  IkanModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.harga,
    required this.status,
  });

  factory IkanModel.fromJson(
      Map<String, dynamic> json) {

    return IkanModel(
      id: json['id_ikan'].toString(),
      nama: json['nama_ikan'].toString(),
      kategori: json['kategori'].toString(),
      jumlah: json['jumlah'].toString(),
      harga: json['harga'].toString(),
      status: json['status_tersedia'].toString(),
    );
  }
}