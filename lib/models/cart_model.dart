class CartModel {
  final Map<String, dynamic> ikan;

  int jumlah;

  bool selected;

  CartModel({
    required this.ikan,
    this.jumlah = 1,
    this.selected = true,
  });

  // Total harga per item
  double get subtotal {
    final harga = double.tryParse(
          ikan["harga"].toString(),
        ) ??
        0;

    return harga * jumlah;
  }
}